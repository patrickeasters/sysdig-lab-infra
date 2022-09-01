output "grafana_admin_pass" {
  value = random_password.grafana_admin.result
  sensitive = true
}