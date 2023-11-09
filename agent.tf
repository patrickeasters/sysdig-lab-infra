resource "helm_release" "sysdig-agent-local" {
  name       = "sysdig"
  namespace  = "sysdig-agent"
  create_namespace = true
  //chart = "/Users/patrick.easters/git/sysdiglabs/charts/charts/sysdig-deploy"
  repository = "https://charts.sysdig.com"
  chart      = "sysdig-deploy"
  version    = "1.29.4"

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
  features:
    kspmAdmissionController: true
  scanner:
    enabled: false

agent:
  psp:
    create: false
  ebpf:
    enabled: true
    kind: universal_ebpf
  prometheus:
    file: true
    yaml:
      scrape_configs:
      - job_name: k8s-cadvisor-disk
        scrape_interval: 60s
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true
        metrics_path: '/metrics/cadvisor'
        kubernetes_sd_configs:
        - role: node
        relabel_configs:
        - action: keep
          source_labels: [__meta_kubernetes_node_address_InternalIP]
          regex: __HOSTIPS__
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
          replacement: kube_node_label_$1
        - replacement: localhost:10250
          target_label: __address__
        - action: replace
          source_labels: [__meta_kubernetes_node_name]
          target_label: kube_node_name
        - action: replace
          source_labels: [__meta_kubernetes_namespace]
          target_label: kube_namespace_name
        metric_relabel_configs:
        - source_labels: [__name__]
          regex: "container_fs_writes_bytes_total|container_fs_reads_bytes_total"
          action: keep
  sysdig:
    settings:
      tags: env:lab
      app_checks_enabled: false
      enrich_with_process_lineage: true
      k8s_command:
        enabled: true
      prometheus_exporter:
        enabled: true
EOF
  ]

}