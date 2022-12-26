
data "aws_eks_cluster" "example" {
  name = aws_eks_cluster.demo.id
}
data "aws_eks_cluster_auth" "example" {
  name = aws_eks_cluster.demo.id
}

# Get information about the TLS certificates securing a host.
data "tls_certificate" "cluster_oidc_issuer_url" {
  url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks-cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_oidc_issuer_url.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.cluster_oidc_issuer_url.url
}

resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Worker policy for the ALB Ingress"

  policy = file("${path.module}/aws-alb-controller-iam_policy.json")
}
module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.0"
  create_role                   = true
  role_name                     = "aws-alb-controller"
  role_description              = <<EOF
                                  The AWS Load Balancer Controller manages AWS Elastic Load Balancers for a Kubernetes cluster. The controller provisions the following resources:
                                  An AWS Application Load Balancer (ALB) when you create a Kubernetes Ingress.
                                  An AWS Network Load Balancer (NLB) when you create a Kubernetes service of type LoadBalancer.
                                  EOF
  provider_url                  = replace(aws_iam_openid_connect_provider.eks-cluster.url, "https://", "")
  role_policy_arns              = [aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]

  tags = {
    Role = "role-with-oidc for aws alb-controller"
  }
}

# create a k8s service account that has the IRSA attached

resource "kubernetes_service_account" "eks-service-account" {
  metadata {
    name = local.k8s_service_account_name # This is used as the serviceAccountName in the spec section of the k8 pod manifest
                                          # it means that the pod can assume the IAM role with the S3 policy attached
    namespace = local.k8s_service_account_namespace
    labels = {
      "app.kubernetes.io/component": "controller"
      "app.kubernetes.io/name": "${local.k8s_service_account_name}"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_admin.iam_role_arn # "arn:aws:iam::880572800141:role/aws-alb-controller"
    }
  }
}


module "iam_assumable_role_s3_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  
  version = "~> 4.0"

  create_role                   = true
  
  role_name                     = "s3-access"
  provider_url                  = replace(aws_iam_openid_connect_provider.eks-cluster.url, "https://", "")
  provider_urls = [
    replace(aws_iam_openid_connect_provider.eks-cluster.url, "https://", "")
  ]

  role_policy_arns              = [
    aws_iam_policy.s3-access.arn
  ]
  
  #oidc_fully_qualified_subjects = ["sts.amazonaws.com"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace_workflows}:${local.k8s_service_account_name_workflow}"]

  tags = {
    Role = "role-with-oidc"
  }
}


resource "aws_iam_policy" "s3-access" {
  name        = "s3-access-artifact-repo"
  description = "s3 access for argo workflows"

  policy = file("${path.module}/s3-access-iam_policy.json")
}

resource "kubernetes_namespace" "workflows" {
  metadata {
    labels = {
      app = "workflows"
    }

    name = "workflows"
  }
}
resource "kubernetes_service_account" "s3-access-service-account" {
  metadata {
    name = local.k8s_service_account_name_workflow # This is used as the serviceAccountName in the spec section of the k8 pod manifest
                                                  # it means that the pod can assume the IAM role with the S3 policy attached
    namespace = local.k8s_service_account_namespace_workflows

    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_s3_access.iam_role_arn
    }
  }
  depends_on = [
    kubernetes_namespace.workflows
  ]
}







module "iam_assumable_role_efs_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.0"

  create_role                   = true
  role_name                     = "efs-access"
  provider_url                  = replace(aws_iam_openid_connect_provider.eks-cluster.url, "https://", "")
  role_policy_arns              = [
        aws_iam_policy.AmazonEKS_EFS_CSI_Driver_Policy.arn
  ]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace_efs-csi-driver}:${local.k8s_service_account_name_efs-csi-driver}"]
}

resource "aws_iam_policy" "AmazonEKS_EFS_CSI_Driver_Policy" {
  name        = "AmazonEKS_EFS_CSI_Driver_Policy"
  description = "Worker policy for access to EFS"

  policy = file("${path.module}/efs-access-iam-policy.json")
}

# a service account for the EFS_CSI_DRIVER will be made by the helm install
