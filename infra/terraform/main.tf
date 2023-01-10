# module "network" {
#   source = "./modules/my-vpc"

#   environment = "dev"
#   cluster-name = var.cluster-name
#   region = var.region
# }

# module "my-eks" {
#     source = "./modules/eks-cluster"

#     cluster-name = var.cluster-name
#     vpc_id = module.network.vpc_id
#     subnets = concat(module.network.vpc_public_subnets,  module.network.vpc_private_subnets)

# }

# module "my-efs" {
#   source = "./modules/efs"

#   subnet_ids           = concat(module.network.vpc_private_subnets)
#   aws_security_group_efs_id     = module.my-eks.efs-sg-rule-id

# }

# module "kubeflow" {
#   source = "./modules/kubeflow"

#   iam-oidc-provider-url = module.my-eks.iam-oidc-provider-url


# }

# module "s3_backend" {
#   source = "./modules/tf-state"
# }

module "argocd" {
  source = "./modules/argocd"

  admin_password = var.admin_password
  insecure       = var.insecure
  #values_file    = var.argocd_values_file
}