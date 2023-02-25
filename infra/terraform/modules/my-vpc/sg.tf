
resource "aws_security_group" "this" {
    name          = "load-balancer-sg"
    description = "ingress-managed aws application load balancer"

    vpc_id = aws_vpc.vpc.id
  
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
}

resource "aws_security_group_rule" "ingress" {
    for_each            = { for rule in var.ingress_rules : rule.description => rule }
    type                = "ingress"
    protocol            = each.value.protocol
    from_port           = each.value.from_port
    to_port             = each.value.to_port
    cidr_blocks         = [each.value.cidr_block]

    description         = each.key

    security_group_id = aws_security_group.this.id
}


# resource "aws_security_group_rule" "worker-nodes-to-alb" {
#     type                = "ingress"
#     protocol            = "-1"
#     from_port           = 0
#     to_port             = 0
#     cidr_blocks         = [aws_vpc.vpc.cidr_block]

#     description         = "traffic back from the worker nodes"

#     security_group_id = aws_security_group.this.id
# }


# add an ingress rule to this security group that allows all 
# inbound traffic using NFS protocol on port 2049 from IP addresses 
# that belong to the CIDR block of the EKS cluster VPC. This rule
# will allow NFS access to the file system from all worker nodes
# in the EKS cluster.
# Security Groups for this volume
resource "aws_security_group" "sg_efs" {
  name        = "efs-access-rule"
  description = "This will allow the cluster to access this volume and use it."
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "NFS For EKS Cluster with an inbound rule that allows inbound NFS traffic for your Amazon EFS mount points."
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

