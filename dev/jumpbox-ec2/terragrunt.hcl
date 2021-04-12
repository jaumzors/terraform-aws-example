include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules//compute/ec2"
}

locals {
  common_vars = yamldecode(file("../commons/vars.yaml"))
}

dependency "public_vpc" {
  config_path                             = "../vpc"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
  mock_outputs = {
    public_subnets  = ["mock-subnet-id"]
    private_subnets = ["mock-subnet-id"]
    vpc_id          = "mock-vpc-id"
    cidr_block      = "mock-cidr-block"
    pub_subnets_regions = {
      0 : "mock-sub-region"
    }
  }
}

inputs = {
  num_of_instances    = 1
  ec2_name            = "jumpbox"
  env                 = local.common_vars.env
  subnet_id           = dependency.public_vpc.outputs.public_subnets[0]
  vpc_id              = dependency.public_vpc.outputs.vpc_id
  ssh_private_key     = "/home/senf/Downloads/default.pem"
  instance_type       = "t2.micro"
  vpc_cidr            = split(", ", dependency.public_vpc.outputs.cidr_block)
  ami_id              = "ami-00ddb0e5626798373"
  az                  = dependency.public_vpc.outputs.pub_subnets_regions[0]
  key_name            = "default"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = [
    {
      from            = 22
      to              = 22
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  egress_rules = [
    {
      from            = 22
      to              = 22
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}
