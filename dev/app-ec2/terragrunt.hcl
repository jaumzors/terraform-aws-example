include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules//compute/ec2"
}

locals {
  common_vars = yamldecode(file("../commons/vars.yaml"))
}

dependency "private_vpc" {
  config_path                             = "../vpc"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
  mock_outputs = {
    public_subnets  = ["mock-subnet-id1", "mock-subnet-id2"]
    private_subnets = ["mock-subnet-id1", "mock-subnet-id2"]
    vpc_id          = "mock-vpc-id"
    cidr_block      = "mock-cidr-block"
    pvt_subnets_regions = {
      0 : "mock-sub-region1"
      1 : "mock-sub-region2"
    }
  }
}

dependency "jumpbox" {
  config_path                             = "../jumpbox-ec2"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
  mock_outputs = {
    "sec_group" = "mock-sec-group"
  }
}

dependency "sg" {
  config_path                             = "../sg"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
  mock_outputs = {
    sg_ids = ["mock-id1", "mock-id2"]
  }
}

dependency "iam_role" {
  config_path                             = "../iam/role"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
  mock_outputs = {
    role_name = "mock-role-name"
  }
}

inputs = {
  num_of_instances = 1
  ec2_name         = "app-ec2"
  env              = local.common_vars.env
  subnet_id        = dependency.private_vpc.outputs.private_subnets[1]
  vpc_id           = dependency.private_vpc.outputs.vpc_id
  ssh_private_key  = "/home/senf/Downloads/default.pem"
  instance_type    = "t2.micro"
  vpc_cidr         = split(", ", dependency.private_vpc.outputs.cidr_block)
  ami_id           = "ami-00ddb0e5626798373"
  az               = dependency.private_vpc.outputs.pvt_subnets_regions[1]
  key_name         = "default"
  jump_box_sec_id  = [dependency.jumpbox.outputs.sec_group]
  user_data        = file("./user_data.sh")
  iam_role_name    = dependency.iam_role.outputs.role_name
  user_data_config = {
    app_external_port = local.common_vars.app_ec2_port
  }
  ingress_rules = [
    {
      from            = local.common_vars.app_ec2_alb_inbound_port
      to              = local.common_vars.app_ec2_port
      cidr_blocks     = []
      security_groups = dependency.sg.outputs.sg_ids
    },
    {
      from            = 22
      to              = 22
      cidr_blocks     = []
      security_groups = [dependency.jumpbox.outputs.sec_group]
    }
  ]
  egress_rules = [
    {
      from            = local.common_vars.app_ec2_alb_inbound_port
      to              = local.common_vars.app_ec2_port
      cidr_blocks     = []
      security_groups = dependency.sg.outputs.sg_ids
    },
    {
      from            = 22
      to              = 22
      cidr_blocks     = []
      security_groups = [dependency.jumpbox.outputs.sec_group]
    },
    {
      from            = 0
      to              = 65535
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}
