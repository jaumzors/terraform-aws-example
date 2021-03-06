resource "aws_security_group" "default" {
  name        = "${var.ec2_name}_sg"
  description = "${var.ec2_name} security group"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.ingress_rules) > 0 ? var.ingress_rules : []
    content {
      from_port       = ingress.value["from"]
      to_port         = ingress.value["to"]
      protocol        = "tcp"
      security_groups = length(ingress.value["security_groups"]) > 0 ? ingress.value["security_groups"] : null
      cidr_blocks     = length(ingress.value["cidr_blocks"]) > 0 ? ingress.value["cidr_blocks"] : null
    }
  }

  dynamic "egress" {
    for_each = length(var.egress_rules) > 0 ? var.egress_rules : []
    content {
      from_port       = egress.value["from"]
      to_port         = egress.value["to"]
      protocol        = "tcp"
      security_groups = length(egress.value["security_groups"]) > 0 ? egress.value["security_groups"] : null
      cidr_blocks     = length(egress.value["cidr_blocks"]) > 0 ? egress.value["cidr_blocks"] : null
    }
  }

}

resource "aws_iam_instance_profile" "default" {
  count = var.iam_role_name != "" ? 1 : 0
  name  = "${var.ec2_name}_profile"
  role  = var.iam_role_name
}

resource "aws_instance" "default" {
  count                = var.num_of_instances
  ami                  = var.ami_id
  instance_type        = var.instance_type
  key_name             = var.key_name
  availability_zone    = var.az
  user_data            = var.user_data != "" ? var.user_data : null
  iam_instance_profile = var.iam_role_name != "" ? aws_iam_instance_profile.default[0].name : null

  subnet_id       = var.subnet_id
  security_groups = [aws_security_group.default.id]

  tags = {
    Name = "${var.ec2_name}_${count.index}"
    Env  = var.env
  }
}

resource "aws_cloudwatch_metric_alarm" "default" {
  count               = var.create_default_ec2_alarms ? var.num_of_instances : 0
  alarm_name          = local.alarms[count.index]["alarm_name"]
  comparison_operator = local.alarms[count.index]["comparison_operator"]
  evaluation_periods  = local.alarms[count.index]["evaluation_periods"]
  metric_name         = local.alarms[count.index]["metric_name"]
  namespace           = local.alarms[count.index]["namespace"]
  period              = local.alarms[count.index]["period"]
  statistic           = local.alarms[count.index]["statistic"]
  threshold           = local.alarms[count.index]["threshold"]
  alarm_description   = local.alarms[count.index]["alarm_description"]
  dimensions = {
    ec2_instance_id = aws_instance.default[count.index].id
    ec2_private_ip  = aws_instance.default[count.index].private_ip
  }
  actions_enabled = false
}