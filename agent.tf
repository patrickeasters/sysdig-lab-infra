resource "helm_release" "sysdig-agent-local" {
  name       = "sysdig"
  namespace  = "sysdig-agent"
  create_namespace = true
  //chart = "/Users/patrick.easters/git/sysdiglabs/charts/charts/sysdig-deploy"
  repository = "https://charts.sysdig.com"
  chart      = "sysdig-deploy"
  version    = "1.5.32"

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
  nodeAnalyzer:
    runtimeScanner:
      deploy: true
      settings:
        eveEnabled: true

admissionController:
  enabled: true

agent:
  sysdig:
    settings:
      tags: env:lab
      app_checks_enabled: false
      k8s_command:
        enabled: true
  prometheus:
    file: true
    yaml:
      global:
        scrape_interval: 10s
      scrape_configs:
      - job_name: k8s-cadvisor
        metrics_path: /metrics/cadvisor
        scheme: https
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        kubernetes_sd_configs:
        - role: node
        relabel_configs:
        - source_labels: [__name__]
          regex: "container_cpu_cfs_throttled_periods_total|container_cpu_cfs_throttled_seconds_total"
          action: keep
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - replacement: kubernetes.default.svc:443
          target_label: __address__
        - regex: (.+)
          replacement: /api/v1/nodes/$1/proxy/metrics/cadvisor
          source_labels:
            - __meta_kubernetes_node_name
          target_label: __metrics_path__
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
EOF
  ]

}