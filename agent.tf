resource "helm_release" "sysdig-agent" {
  name       = "sysdig"
  namespace  = "sysdig-agent"
  create_namespace = true
  repository = "https://charts.sysdig.com"
  chart      = "sysdig-deploy"
  version    = "1.3.7"

  values = [ <<EOF
global:
  sysdig:
    accessKey: ${var.sysdig_agent_access_key}
    region: ${var.sysdig_region}
  clusterConfig:
    name: ${var.eks_cluster_name}
  kspm:
    deploy: true

nodeAnalyzer:
  nodeAnalyzer:
    runtimeScanner:
      settings:
        eveEnabled: true
  secure:
    vulnerabilityManagement:
      newEngineOnly: true
EOF
  ]

}

resource "helm_release" "sysdig-admission" {
  name       = "sysdig-admission-controller"
  namespace  = "sysdig-admission-controller"
  create_namespace = true
  repository = "https://charts.sysdig.com"
  chart      = "admission-controller"
  version    = "0.6.19"

  values = [ <<EOF
sysdig:
  url: ${var.sysdig_secure_url}/
  secureAPIToken: ${var.sysdig_secure_api_token}
clusterName: ${var.eks_cluster_name}
features:
  k8sAuditDetections: true
EOF
  ]

}
