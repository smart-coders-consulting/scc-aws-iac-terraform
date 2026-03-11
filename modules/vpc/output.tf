output "vpc_ids" {
  value = { for k, v in aws_vpc.this : k => v.id }
}

output "public_subnet_ids" {
  value = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnet_ids" {
  value = { for k, v in aws_subnet.private : k => v.id }
}

output "private_route_table_ids" {
  value = { for k, v in aws_route_table.private : k => v.id }
}

output "public_route_table_ids" {
  value = { for k, v in aws_route_table.public : k => v.id }
}

output "vpc_cidrs" {
  value = { for k, v in aws_vpc.this : k => v.cidr_block }
}
