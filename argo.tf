resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  create_namespace = true
  repository = "https://argoproj.github.io/argo-helm/"
  chart      = "argo-cd"
  version    = "4.10.8"
  
  values = [ <<EOF
server:
  extraArgs:
    - '--insecure' # TLS is terminated by ingress controller
  ingress:
    enabled: true
    hosts:
      - ${var.argocd_hostname}
  config:
    url: https://${var.argocd_hostname}
    dex.config: |
      connectors:
        - type: github
          id: github
          name: GitHub
          config:
            clientID: ${var.argocd_github_client_id}
            clientSecret: ${var.argocd_github_client_secret}
            orgs:
            - name: ${var.argocd_github_org}
  rbacConfig:
    policy.csv: |
      g, ${var.argocd_github_org}:${var.argocd_github_admin_team}, role:admin
    policy.default: role:readonly
EOF
  ]
}

# install sock shop app
resource "kubernetes_manifest" "sock_shop_app" {
  count = ( var.first_run ? 0 : 1 )
  manifest = yamldecode(<<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sock-shop
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/totallyfakebusiness/sock-shop.git
    targetRevision: main
    path: deploy/kubernetes/manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: sock-shop
  syncPolicy:
    automated:
      prune: true
      allowEmpty: true
EOF
  )

  depends_on = [
    helm_release.argocd
  ]
}
