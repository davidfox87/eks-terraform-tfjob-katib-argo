variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  type        = string
  description = "The Deployment environment"
}


# variable "public_subnet_numbers" {
#   type = tomap(number)
#   description = "Map of AZ to a number that should be used for public subnets"
#   default = {
#     "us-west-1a" = 1
#     "us-west-1b" = 2
#   }
# }

# variable "private_subnet_numbers" {
#   type = tomap(number)
#   description = "Map of AZ to a number that should be used for private subnets"
#   default = {
#     "us-west-1a" = 3
#     "us-west-1b" = 4
#   }

# }
variable "cluster-name" {
  type        = string
  description = "eks-cluster"
}