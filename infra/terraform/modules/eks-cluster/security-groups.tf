resource "aws_security_group" "cluster_security_group" {
  name        = "terraform-eks-demo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster-name}" = "owned"
  }
}




# # Security Groups for this volume
# resource "aws_security_group" "allow_eks_cluster" {
#   name        = "efs-access-rule"
#   description = "This will allow the cluster to access this volume and use it."
#   vpc_id      = "${var.vpc_id}"

#   ingress {
#     description = "NFS For EKS Cluster ${var.cluster-name} with an inbound rule that allows inbound NFS traffic for your Amazon EFS mount points."
#     from_port   = 2049
#     to_port     = 2049
#     protocol    = "tcp"
#     security_groups = ["${aws_security_group.cluster_security_group.id}"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "efs rule"
#   }
# }