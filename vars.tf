variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "eks_cluster_name" {
  type = string
  default = "cs-dev"
}

variable "cloudflare_api_token" {
  type = string
  sensitive = true
}

variable "cloudflare_argo_zone_id" {
  type = string
}

variable "argocd_github_client_id" {
  type = string
}

variable "argocd_github_client_secret" {
  type = string
  sensitive = true
}

variable "argocd_github_org" {
  type = string
}

variable "argocd_github_admin_team" {
  type = string
  default = "devops"
}

variable "argocd_hostname" {
  type = string
}

variable "grafana_hostname" {
  type = string
}

variable "grafana_github_client_id" {
  type = string
}

variable "grafana_github_client_secret" {
  type = string
  sensitive = true
}

variable "grafana_github_org" {
  type = string
}

variable "sysdig_secure_api_token" {
  type = string
  sensitive = true
}

variable "sysdig_secure_url" {
  type = string
}

variable "sysdig_monitor_api_token" {
  type = string
  sensitive = true
}

variable "sysdig_monitor_url" {
  type = string
}

variable "sysdig_region" {
  type = string
}
variable "sysdig_agent_access_key" {
  type = string
  sensitive = true
}