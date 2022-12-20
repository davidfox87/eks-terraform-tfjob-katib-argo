provider "aws" {
  region = var.region
}

resource "aws_eks_cluster" "demo" {
  name            = "${var.cluster-name}"
  version         = var.kubernetes_version
  role_arn        = "${aws_iam_role.eks-iam-role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.cluster_security_group_id.id}"]
    subnet_ids         =  "${var.subnets}"
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]
}

resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "example-nodes"
  node_role_arn   = aws_iam_role.workernodes.arn
  subnet_ids      = [var.subnets[2], var.subnets[3]] # private subnets
  
  # Maximum number of pods – Since each pod is assigned its own IP address, 
  # the number of IP addresses supported by an instance type is a factor in 
  # determining the number of pods that can run on the instance. To manually
  # determine how many pods an instance type supports, see Amazon EKS 
  # recommended maximum pods for each Amazon EC2 instance type.

  instance_types = [var.machine_type]
  scaling_config {
    desired_size = var.min_node_count
    max_size     = var.max_node_count
    min_size     = var.min_node_count
  }

  tags = {
    "alpha.eksctl.io/cluster-name" = "${var.cluster-name}"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "${var.cluster-name}"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
  timeouts {
    create = "15m"
    update = "1h"
  }
}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "kube-proxy"
      version = "v1.21.2-eksbuild.2"
    },
    {
      name    = "vpc-cni"
      version = "v1.10.1-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.8.4-eksbuild.1"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.4.0-eksbuild.preview"
    }
  ]
}


resource "aws_eks_addon" "addons" {
  for_each          = { for addon in var.addons : addon.name => addon }
  cluster_name      = aws_eks_cluster.demo.id
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts = "OVERWRITE"
  depends_on = [aws_eks_node_group.example] 
}







provider "helm" {
    kubernetes {
    host                   = data.aws_eks_cluster.example.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster-name]
      command     = "aws"
    }
  }
}

# The Terraform Helm provider contains the helm_release resource that deploys 
# a Helm chart to a Kubernetes cluster. The helm_release resource specifies the
# chart name and the configuration variables for your deployment.

# Installs helm chart for the aws-load-balancer-controller.
resource "helm_release" "ingress" {

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace = "kube-system"
  set {
    name  = "region"
    value = "us-west-1"
  }
  set {
    name  = "vpcId"
    value =  "${var.vpc_id}"
  }
  set {
    name  = "image.repository"
    value =  "602401143452.dkr.ecr.us-west-1.amazonaws.com/amazon/aws-load-balancer-controller"
  }
  set {
    name  = "clusterName"
    value =  "${var.cluster-name}"
  }
  set {
    name  = "serviceAccount.create"
    value =  "false"
  }

  set {
    name  = "serviceAccount.name"
    value =  "aws-load-balancer-controller"
  }
}




# automatically retrieve the access credentials for your cluster and configure kubectl
resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks  --region ${var.region} update-kubeconfig --name ${var.cluster-name}"
  }
  depends_on = [
    aws_eks_cluster.demo,
  ]
}
