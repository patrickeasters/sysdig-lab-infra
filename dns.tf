
data "aws_route53_zone" "lab_domain" {
  name = var.ingress_domain
}

resource "aws_route53_record" "ingress" {
  zone_id = data.aws_route53_zone.lab_domain.zone_id
  name    = "*"
  type    = "CNAME"
  ttl     = 300
  records = [data.kubernetes_service.caddy.status.0.load_balancer.0.ingress.0.hostname]
}