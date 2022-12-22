# Get information about the TLS certificates securing a host.
data "tls_certificate" "cluster_oidc_issuer_url" {
  url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}

resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Worker policy for the ALB Ingress"

  policy = file("${path.module}/iam-policies/aws-alb-controller-iam_policy.json")
}
module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "aws-alb-controller"
  role_description              = <<EOF
                                  The AWS Load Balancer Controller manages AWS Elastic Load Balancers for a Kubernetes cluster. The controller provisions the following resources:
                                  An AWS Application Load Balancer (ALB) when you create a Kubernetes Ingress.
                                  An AWS Network Load Balancer (NLB) when you create a Kubernetes service of type LoadBalancer.
                                  EOF
  provider_url                  = replace(tls_certificate.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]

  tags = {
    Role = "role-with-oidc for aws alb-controller"
  }
}

# create a k8s service account that has the IRSA attached

provider "kubernetes" {
  host                   = data.aws_eks_cluster.example.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster-name]
    command     = "aws"
  }
}
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
  role_policy_arns              = [aws_iam_policy.s3_access.arn]
  oidc_fully_qualified_subjects = ["${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
}
resource "aws_iam_policy" "s3-access" {
  name        = "s3-access-artifact-repo"
  description = "s3 access for argo workflows"

  policy = file("${path.module}/iam-policies/s3-access-worker.json.json")
}

resource "kubernetes_namespace" "example" {
  metadata {
    labels = {
      app = "workflows"
    }

    name = "workflows"
  }
}
resource "kubernetes_service_account" "s3-access-service-account" {
  metadata {
    name = local.k8s_service_account_name_s3access # This is used as the serviceAccountName in the spec section of the k8 pod manifest
                                                  # it means that the pod can assume the IAM role with the S3 policy attached
    namespace = local.k8s_service_account_namespace_workflows

    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_s3_access.iam_role_arn
    }
  }
}







module "iam_assumable_role_efs_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.0"

  create_role                   = true
  role_name                     = "efs-access"
  provider_url                  = replace(aws_iam_openid_connect_provider.eks-cluster.url, "https://", "")
  role_policy_arns              = [aws_iam_policy.AmazonEKS_EFS_CSI_Driver_Policy.arn]
  oidc_fully_qualified_subjects = ["${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
}

resource "aws_iam_policy" "AmazonEKS_EFS_CSI_Driver_Policy" {
  name        = "AmazonEKS_EFS_CSI_Driver_Policy"
  description = "Worker policy for access to EFS"

  policy = file("${path.module}/policies/efs-access-iam_policy.json")
}

resource "kubernetes_namespace" "kubernetes_efs_csi_driver" {
  metadata {
    name = "kube-system"
  }
}
resource "kubernetes_service_account" "efs-csi-driver-service-account" {
  metadata {
    name = local.k8s_service_account_name_efs-csi-driver # This is used as the serviceAccountName in the spec section of the k8 pod manifest
                                                  # it means that the pod can assume the IAM role with the S3 policy attached
    namespace = local.k8s_service_account_namespace_efs-csi-driver

    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_efs_access.iam_role_arn
    }
  }
}