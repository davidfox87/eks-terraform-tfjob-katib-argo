module "network" {
  source = "./modules/my-vpc"

  environment = "dev"
  cluster-name = var.cluster-name
  region = var.region
}

module "my-eks" {
    source = "./modules/eks-cluster"

    cluster-name = var.cluster-name
    vpc_id = module.network.vpc_id
    subnets = concat(module.network.vpc_public_subnets,  module.network.vpc_private_subnets)

}

module "my-efs" {
  source = "./modules/efs"

  subnet_ids           = concat(module.network.vpc_private_subnets)
  aws_security_group_efs_id     = module.my-eks.efs-sg-rule-id
  cluster-name        = var.cluster-name

  depends_on = [
    module.my-eks # depends on Amazon EFS CSI driver install using Helm
  ]
}




# data "aws_eks_cluster" "default" {
#   name = var.cluster_name
# }

# data "aws_eks_cluster_auth" "default" {
#   name = var.cluster_name
# }

# resource "local_file" "kubeconfig" {
#   sensitive_content = templatefile("${path.module}/kubeconfig.tpl", {
#     cluster_name = var.cluster_name,
#     clusterca    = data.aws_eks_cluster.default.certificate_authority[0].data,
#     endpoint     = data.aws_eks_cluster.default.endpoint,
#   })
#   filename = "./kubeconfig-${var.cluster_name}"
# }