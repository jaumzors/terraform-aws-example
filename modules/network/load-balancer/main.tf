resource "aws_alb" "default" {
  name               = var.lb_name
  internal           = var.lb_internal
  load_balancer_type = var.lb_type
  security_groups    = var.lb_sec_group
  subnets            = var.lb_subnets

  tags = {
    Environment = var.env
  }
}

resource "aws_lb_target_group" "default" {
  for_each = {
    for tg_name, group in local.tg_group_attachment :
    tg_name => group
  }
  name     = each.value["tg_name"]
  port     = each.value["port"]
  protocol = each.value["protocol"]
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "default" {
  for_each         = local.instances
  target_group_arn = aws_lb_target_group.default[each.value.tg_name].arn
  target_id        = each.value.id
  port             = each.value.port
}

resource "aws_lb_listener" "front" {
  for_each          = local.listeners
  load_balancer_arn = aws_alb.default.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default[each.value.tg_name].arn
  }
}