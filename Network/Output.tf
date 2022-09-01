output "vpc_id" {
  value = aws_vpc.three_tier_system.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.three_tier_rds_subnetgroup.*.name
}

output "rds_db_subnet_group" {
  value = aws_db_subnet_group.three_tier_rds_subnetgroup.*.id
}

output "rds_sg" {
  value = aws_security_group.three_tier_rds_sg.id
}

output "frontend_app_sg" {
  value = aws_security_group.application_security_group1.id
}

output "backend_app_sg" {
  value = aws_security_group.application_security_group2.id
}

output "bastion_sg" {
  value = aws_security_group.bastion_security_group.id
}

output "lb_sg" {
  value = aws_security_group.loadbalancer_security_group.id
}

output "public_subnets" {
  value = aws_subnet.public_subnets.*.id
}

output "private_subnets" {
  value = aws_subnet.private_subnets.*.id
}

output "private_subnets_db" {
  value = aws_subnet.three_tier_private_subnets_db.*.id
}