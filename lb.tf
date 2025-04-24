# LoadBalancer Public
resource "aws_lb" "public" {
  name               = format("%s-public-lb", local.name)
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb_sg.id]

  tags = merge(
    { Name = format("%s-lb", local.name) },
    local.tags
  )
}

resource "aws_lb_target_group" "public" {
  count    = length(var.public_rule)
  name     = format("%s-%s", local.name, count.index)
  port     = var.public_rule[count.index].port
  protocol = var.public_rule[count.index].protocol
  vpc_id   = var.vpc_id

  health_check {
    port     = lookup(var.public_rule[count.index], "health_check_port", null)
    protocol = lookup(var.public_rule[count.index], "health_check_protocol", null)
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_lb_listener" "public" {
  count             = length(var.public_rule)
  load_balancer_arn = aws_lb.public.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = var.alb_certificate_arn
  ssl_policy      = var.alb_ssl_policy


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public[count.index].arn
  }
}
