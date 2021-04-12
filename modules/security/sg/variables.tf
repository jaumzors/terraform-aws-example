variable "ingress_rules" {
  type = list(object({
    from        = string
    to          = string
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress_rules" {
  type = list(object({
    from        = string
    to          = string
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "sg_name" {
  type = string
}

variable "vpc_id" {
  type = string
}