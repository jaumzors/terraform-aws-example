output "vpc_id" {
  value = aws_vpc.default.id
}

output "cidr_block" {
  value = aws_vpc.default.cidr_block
}

output "private_subnets" {
  value = [for sub in aws_subnet.private_subnets[*] : sub.id]
}

output "public_subnets" {
  value = [for sub in aws_subnet.public_subnets[*] : sub.id]
}

output "pvt_subnets_regions" {
  value = { for idx, sub in aws_subnet.private_subnets[*] : idx => sub.availability_zone }
}

output "pub_subnets_regions" {
  value = { for idx, sub in aws_subnet.public_subnets[*] : idx => sub.availability_zone }
}