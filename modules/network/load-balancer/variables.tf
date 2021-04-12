variable "tg_groups" {
  type = list(object({
    lb_tg_name     = string
    lb_tg_port     = string
    lb_tg_protocol = string
  }))
}

variable "listeners" {
  type = list(object({
    port     = string
    protocol = string
    tg_name  = string
  }))
}

variable "instances" {
  type = list(object({
    id      = string
    tg_name = string
    port    = string
  }))
}

variable "env" {
  type = string
}

variable "lb_name" {
  type = string
}

variable "lb_sec_group" {
  type = list(string)
}

variable "lb_subnets" {
  type = list(string)
}

variable "lb_type" {
  type    = string
  default = "application"
}

variable "lb_internal" {
  type    = bool
  default = false
}

variable "vpc_id" {
  type = string
}