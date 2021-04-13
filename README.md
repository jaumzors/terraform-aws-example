# Terraform (Terragrunt) Deployment Example

This repo contains Terraform code that deploys a simple web page on ports 8080 and 443 in an EC2 on AWS.

It also deploys the following:
- VPC
- Private and Public subnets
- Internet Gateway
- NAT Gateway
- Security groups
- Jumpbox EC2 for debugging
- Cloudwatch Alerts for a few EC2 metrics

# How to use it

Configure you AWS access key and secret or setup you default profile and:

```bash
git clone https://github.com/jaumzors/terraform-aws-example.git
cd terraform-aws-example/dev
terragrunt apply-all
```

# AWS Architecture

![AWS](/imgs/aws.png)