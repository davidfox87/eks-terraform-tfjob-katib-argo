locals {
  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.demo.endpoint}
    certificate-authority-data: ${aws_eks_cluster.demo.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster-name}"
KUBECONFIG
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "cluster_id" {
  value = aws_eks_cluster.demo.id
}

output "cluster_name" {
  value = aws_eks_cluster.demo.name
}


output "cluster_oidc_issuer" {
  value = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}

output "ca" {
  value = aws_eks_cluster.demo.certificate_authority[0].data
}
output "efs-sg-rule-id" {
  value = aws_security_group.allow_eks_cluster.id
}

output "iam-oidc-provider-url" {
  value = aws_iam_openid_connect_provider.eks-cluster.url
}

output "worker_role" {
  value = aws_iam_role.workernodes.arn
}



