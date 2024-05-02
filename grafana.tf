resource "random_password" "grafana_admin" {
  length  = 50
  special = true
}

resource "helm_release" "grafana" {
  name             = "grafana"
  namespace        = "grafana"
  create_namespace = true
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  version          = "6.56.5"

  values = [<<EOF
ingress:
  enabled: true
  hosts:
    - grafana.${var.ingress_domain}

adminPassword: "${random_password.grafana_admin.result}"

grafana.ini:
  server:
    root_url: https://grafana.${var.ingress_domain}/
  auth.github:
    enabled: true
    allow_sign_up: true
    scopes: user:email,read:org
    auth_url: https://github.com/login/oauth/authorize
    token_url: https://github.com/login/oauth/access_token
    api_url: https://api.github.com/user
    allowed_organizations: ${var.grafana_github_org}
    client_id: ${var.grafana_github_client_id}
    client_secret: ${var.grafana_github_client_secret}
  users:
    auto_assign_org_role: Editor
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Sysdig Prom
      type: prometheus
      url: ${var.sysdig_monitor_url}/prometheus
      access: proxy
      isDefault: true
      jsonData:
        httpHeaderName1: Authorization
      secureJsonData:
        httpHeaderValue1: Bearer ${var.sysdig_monitor_api_token}
EOF
  ]
}