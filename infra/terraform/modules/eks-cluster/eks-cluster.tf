provider "aws" {
  region = var.region
}

resource "aws_eks_cluster" "demo" {
  name            = "${var.cluster-name}"
  version         = var.kubernetes_version
  role_arn        = "${aws_iam_role.eks-iam-role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.cluster_security_group.id}"]
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


resource "aws_eks_addon" "addons" {
  for_each          = { for addon in var.addons : addon.name => addon }
  cluster_name      = aws_eks_cluster.demo.id
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts = "OVERWRITE"
  depends_on = [aws_eks_node_group.example] 
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



data "aws_eks_cluster" "example" {
  name = aws_eks_cluster.demo.id
}
data "aws_eks_cluster_auth" "example" {
  name = aws_eks_cluster.demo.id
}
# Get information about the TLS certificates securing a host.

# Get information about the TLS certificates securing a host.
data "tls_certificate" "demo" {
  url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}


# https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner/blob/master/kubeconfig.tf