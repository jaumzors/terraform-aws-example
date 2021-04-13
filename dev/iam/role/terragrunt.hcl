include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules//security/iam"
}

locals {
  common_vars            = yamldecode(file("../../commons/vars.yaml"))
  assume_policy_document = file("../../../commons/templates/iam/ec2-assume-role.json")
}

inputs = {
  role_name          = "app-ec2-cw-agent-role"
  policy_arn         = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  assume_role_policy = local.assume_policy_document
  env                = local.common_vars.env
}
