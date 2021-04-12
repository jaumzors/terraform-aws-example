include {
  path = find_in_parent_folders()
}

locals {
  common_vars = yamldecode(file("../commons/vars.yaml"))
}

terraform {
  source = "../../modules//network/load-balancer"
}

dependency "vpc" {
  config_path                             = "../vpc"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
  mock_outputs = {
    public_subnets  = ["mock-subnet-id1", "mock-subnet-id2"]
    private_subnets = ["mock-subnet-id1", "mock-subnet-id2"]
    vpc_id          = "mock-vpc-id"
    cidr_block      = "mock-cidr-block"
    pub_subnets_regions = {
      0 : "mock-sub-region"
    }
  }
}

dependency "sg" {
  config_path                             = "../sg"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
  mock_outputs = {
    sg_ids = ["mock-id1", "mock-id2"]
  }
}

dependency "instances" {
  config_path                             = "../app-ec2"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
  mock_outputs = {
    instance_ids = ["mock-id1", "mock-id2"]
  }
}

inputs = {

  instances = [
    {
      id      = dependency.instances.outputs.instance_ids[0]
      tg_name = "front-end-http"
      port    = 8080
    }
  ]

  listeners = [
    {
      port     = "8080"
      protocol = "HTTP"
      tg_name  = "front-end-http"
    }
  ]

  tg_groups = [
    {
      lb_tg_name     = "front-end-http"
      lb_tg_port     = "8080"
      lb_tg_protocol = "HTTP"
    }
  ]

  env          = local.common_vars.env
  vpc_id       = dependency.vpc.outputs.vpc_id
  lb_name      = "app-lb"
  lb_sec_group = dependency.sg.outputs.sg_ids
  lb_subnets   = [dependency.vpc.outputs.public_subnets[0], dependency.vpc.outputs.public_subnets[1], dependency.vpc.outputs.private_subnets[1]]
}