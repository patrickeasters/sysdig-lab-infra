resource "helm_release" "sysdig-agent-local" {
  name       = "sysdig"
  namespace  = "sysdig-agent"
  create_namespace = true
  //chart = "/Users/patrick.easters/git/sysdiglabs/charts/charts/sysdig-deploy"
  repository = "https://charts.sysdig.com"
  chart      = "sysdig-deploy"
  version    = "1.9.2"

  values = [ <<EOF
global:
  sysdig:
    accessKey: ${var.sysdig_agent_access_key}
    region: ${var.sysdig_region}
    secureAPIToken: ${var.sysdig_secure_api_token}
  clusterConfig:
    name: ${var.eks_cluster_name}
  kspm:
    deploy: true
    
nodeAnalyzer:
  psp:
    create: false
  nodeAnalyzer:
    runtimeScanner:
      deploy: true
      settings:
        eveEnabled: true

admissionController:
  enabled: true

agent:
  psp:
    create: false
  sysdig:
    settings:
      tags: env:lab
      app_checks_enabled: false
      enrich_with_process_lineage: true
      k8s_command:
        enabled: true
EOF
  ]

}