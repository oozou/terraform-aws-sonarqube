data "aws_route53_zone" "this" {
  count = var.is_create_route53_reccord ? 1 : 0
  name  = var.route53_zone_name
}

resource "aws_route53_record" "public" {
  count   = var.is_create_route53_reccord ? 1 : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = format("%s.%s", var.public_lb_domain, var.route53_zone_name)
  type    = "A"
  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }
}

