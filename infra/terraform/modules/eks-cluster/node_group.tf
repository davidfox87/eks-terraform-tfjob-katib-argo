resource "aws_eks_node_group" "example" {
  cluster_name    = var.cluster-name
  node_group_name = format("ng1-%s", var.cluster-name)
  node_role_arn   = aws_iam_role.workernodes.arn
  subnet_ids      = var.subnets # private subnets

  instance_types = [var.instance_type]
  scaling_config {
    desired_size = var.min_node_count
    max_size     = var.max_node_count
    min_size     = var.min_node_count
  }

  tags = {
    "alpha.eksctl.io/cluster-name"      = "${var.cluster-name}"
    "alpha.eksctl.io/nodegroup-name"    = format("ng1-%s", "${var.cluster-name}")
    "alpha.eksctl.io/nodegroup-type"    = "managed"
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  timeouts {}

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.demo,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]

}