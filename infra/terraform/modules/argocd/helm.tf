resource "helm_release" "argocd" {
  namespace = "argocd"
  create_namespace = true
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.16.14"

  # Helm chart deployment can sometimes take longer than the default 5 minutes
  timeout = 800

  # If values file specified by the var.values_file input variable exists then apply the values from this file
  # else apply the default values from the chart
  values = [fileexists("${path.root}/${var.values_file}") == true ? file("${path.root}/${var.values_file}") : ""]

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = ""
  }

  set {
    name  = "server.extraArgs"
    value = var.insecure == false ? "" : "{--insecure}"
  }

  set {
    name  = "dex.enabled"
    value = var.enable_dex == true ? true : false
  }
}

# app of apps. this helm chart will install all of the apps in the source specified 
# in the values.yaml file
resource "helm_release" "apps" {
  namespace = "argocd"
  create_namespace = false
  name             = "argocd-apps"
  repository       = "https://davidfox87.github.io/app-of-apps-helm/"
  chart            = "argocd-example-infra"
  version          = "0.1.0"

  values = [fileexists("${path.root}/${var.app_of_apps_values_file}") == true ? file("${path.root}/${var.app_of_apps_values_file}") : ""]
  
  depends_on = [
    helm_release.argocd
  ]
}