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


