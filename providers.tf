terraform {
  required_providers {
    sysdig = {
      source = "sysdiglabs/sysdig"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}
