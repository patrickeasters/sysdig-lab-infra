provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_record" "foobar" {
  zone_id = var.cloudflare_argo_zone_id
  name    = "*"
  value   = data.kubernetes_service.caddy.status.0.load_balancer.0.ingress.0.hostname
  type    = "CNAME"
  ttl     = 300
}
