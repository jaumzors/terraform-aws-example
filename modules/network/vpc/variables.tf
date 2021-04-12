
variable "vpc_cidr_block" {
  type        = string
  description = "Cidr block principal"
}

variable "vpc_name" {
  type        = string
  description = "Nome da vpc"
}

variable "private_subnets" {
  type        = list(string)
  description = "Lista de cidrs das subnets privadas"
}

variable "public_subnets" {
  type        = list(string)
  description = "Lista de cidrs de subnets publicas"
}

variable "nat_gateway_pub_subnet_index" {
  type = string
}

variable "nat_gateway_pvt_subnet_index" {
  type = string
}

variable "env" {
  type = string
}