output "grafana_admin_pass" {
  value = random_password.grafana_admin.result
  sensitive = true
}

output "cloudwatch_role_name" {
  value = module.sysdig_cloudwatch_stream.aws_iam_role_name
}

output "cloudwatch_account_id" {
  value = module.sysdig_cloudwatch_stream.aws_account_id
}