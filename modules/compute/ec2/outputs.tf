output "public_ip" {
  value = [for instance in aws_instance.default : instance.public_ip]
}

output "sec_group" {
  value = aws_security_group.default.id
}

output "instance_ids" {
  value = [for instance in aws_instance.default : instance.id]
}