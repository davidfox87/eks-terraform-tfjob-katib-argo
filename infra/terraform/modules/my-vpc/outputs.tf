output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "alb-sg" {
  value = aws_security_group.this.id
}

output "sg_efs" {
  value = aws_security_group.sg_efs.id
}