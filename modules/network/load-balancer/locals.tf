locals {

  instances = {
    for instance in var.instances :
    instance["tg_name"] => {
      id : instance["id"]
      port : instance["port"]
      tg_name : instance["tg_name"]
    }
  }

  listeners = {
    for listener in var.listeners :
    listener["tg_name"] => {
      port : listener["port"]
      protocol : listener["protocol"]
      tg_name : listener["tg_name"]
    }
  }

  tg_group_attachment = {
    for group in var.tg_groups :
    group["lb_tg_name"] => {
      tg_name : group["lb_tg_name"]
      protocol : group["lb_tg_protocol"]
      port : group["lb_tg_port"]
    }
  }

}