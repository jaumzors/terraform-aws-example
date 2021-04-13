include {
  path = find_in_parent_folders()
}

locals {
  common_vars = yamldecode(file("../commons/vars.yaml"))
}

terraform {
  source = "../../modules//security/sg"
}

dependency "vpc" {
  config_path                             = "../vpc"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
  mock_outputs = {
    public_subnets  = ["mock-subnet-id"]
    private_subnets = ["mock-subnet-id"]
    vpc_id          = "mock-vpc-id"
    cidr_block      = "mock-cidr-block"
    pub_subnets_regions = {
      "mock-sec-group" : "mock-sub-region"
    }
  }
}

inputs = {

  sg_name = "front-end"

  vpc_id = dependency.vpc.outputs.vpc_id

  ingress_rules = [
    {
      from        = "443"
      to          = "8080"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from        = "443"
      to          = "8080"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}