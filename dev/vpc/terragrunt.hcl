include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules//network/vpc"
}

locals {
  common_vars = yamldecode(file("../commons/vars.yaml"))
}

inputs = {
  vpc_cidr_block               = "192.168.0.0/22"
  vpc_name                     = "test-vpc"
  private_subnets              = ["192.168.0.0/24", "192.168.1.0/24"]
  public_subnets               = ["192.168.2.0/24", "192.168.3.0/24"]
  nat_gateway_pub_subnet_index = 0
  nat_gateway_pvt_subnet_index = 1
  env                          = local.common_vars.env
}