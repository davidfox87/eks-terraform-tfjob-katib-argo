module "vpc" {
  source = "./modules/my-vpc"

  # set vpc cidr block here so it can be modified depending on env
  name            = "dev-eks-vpc"
  cidr            = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  private_subnet_names = ["Private Subnet One", "Private Subnet Two"]
  public_subnet_names = ["Public Subnet One", "Public Subnet Two"]

    # provision load balancer in public subnets
  public_subnet_tags = {
     "kubernetes.io/cluster/${var.cluster-name}" = "shared"
     "kubernetes.io/role/elb" = "1" # This is so that Kubernetes knows to use only the subnets that are specified for external load balancers.
  }

  environment     = "dev"
  cluster-name    = var.cluster-name
  region          = var.region
}

module "my-eks" {
  source = "./modules/eks-cluster"
  cluster-name                    = var.cluster-name
  cluster_version                 = "1.24"
  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.private_subnets
  control_plane_subnet_ids        = module.vpc.public_subnets

  instance_type = "t2.medium"
  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  map_additional_roles = [
    {
      rolearn   = "arn:aws:iam::233532778289:role/dsEKSAdminRole"
      username  = "eks-admin"
      groups    = ["system:masters"]
    },
    {
      rolearn   = "arn:aws:iam::233532778289:role/dsEKSDeveloperRole"
      username  = "eks-developer"
      groups    = [""] # add to groups using rbac roles and role bindings
    }
  ]
  
}

# module "argocd" {
#   source = "../modules/argocd"

#   admin_password = var.admin_password
#   insecure       = var.insecure
#   argocd_ingress_enabled = true
#   argocd_server_host = var.argocd-url
  
#   depends_on = [
#     module.my-eks
#   ]
# }