provider "sysdig" {
  sysdig_secure_url       = var.sysdig_secure_url
  sysdig_secure_api_token = var.sysdig_secure_api_token
}

module "single-account-cspm" {
  source           = "draios/secure-for-cloud/aws//modules/services/trust-relationship"
  role_name        = "sysdig-secure-1y8n"
  trusted_identity = "arn:aws:iam::263844535661:role/us-west-2-production-secure-assume-role"
  external_id      = "01a4d6296cc2aecdde324d9e0820d966"
}

module "single-account-threat-detection" {
  source           = "draios/secure-for-cloud/aws//modules/services/cloud-logs"
  trusted_identity = "arn:aws:iam::263844535661:role/us-west-2-production-secure-assume-role"
  external_id      = "01a4d6296cc2aecdde324d9e0820d966"
  role_name        = "sysdig-secure-cloudlogs-3uoh"
  bucket_arn       = "arn:aws:s3:::aws-cloudtrail-logs-607989492804-7d841f0f"
}

