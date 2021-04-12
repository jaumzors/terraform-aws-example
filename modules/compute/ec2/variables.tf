variable "ec2_name" {
  type = string
}

variable "env" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "az" {
  type = string
}

variable "num_of_instances" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "ssh_private_key" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "jump_box_sec_id" {
  type    = list(string)
  default = null
}

variable "ingress_cidr_blocks" {
  type    = list(string)
  default = null
}

variable "key_name" {
  type = string
}

variable "ingress_rules" {
  type = list(object({
    from            = string
    to              = string
    security_groups = list(string)
    cidr_blocks     = list(string)
  }))
  default = []
}

variable "egress_rules" {
  type = list(object({
    from            = string
    to              = string
    security_groups = list(string)
    cidr_blocks     = list(string)
  }))
  default = []
}

variable "alb_sg" {
  type    = list(string)
  default = []
}

variable "user_data" {
  type    = string
  default = ""
}

variable "user_data_config" {
  type    = any
  default = null
}

variable "iam_role_name" {
  type    = string
  default = ""
}