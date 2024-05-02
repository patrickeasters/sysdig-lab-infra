module "sysdig_cloudwatch_stream" {
  source = "github.com/patrickeasters/sysdig-cloudwatch-terraform"

  sysdig_monitor_url = var.sysdig_monitor_url
  sysdig_monitor_api_token = var.sysdig_monitor_api_token
}