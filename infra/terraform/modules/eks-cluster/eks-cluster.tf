resource "aws_eks_cluster" "demo" {
  name            = "${var.cluster-name}"
  version         = var.cluster_version
  role_arn        = "${aws_iam_role.eks-iam-role.arn}"

  vpc_config {
    security_group_ids = [aws_security_group.cluster_security_group.id]
    subnet_ids         =  var.control_plane_subnet_ids
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]
}


resource "aws_eks_addon" "addons" {
  for_each = { for k, v in var.addons : k => v }

  cluster_name          = aws_eks_cluster.demo.name
  addon_name            = each.key
  addon_version         = try(each.value.addon_version, data.aws_eks_addon_version.this[each.key].version)
  resolve_conflicts     = "OVERWRITE"
  depends_on = [
    aws_eks_node_group.example
  ] 
}

data "aws_eks_addon_version" "this" {
  for_each = { for k, v in var.addons : k => v }

  addon_name         = each.key
  kubernetes_version = var.cluster_version
  most_recent        = each.value.most_recent
}


