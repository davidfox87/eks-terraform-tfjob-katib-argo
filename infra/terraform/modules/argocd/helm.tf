resource "helm_release" "argocd" {
  create_namespace = true
  namespace = "argocd"
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.21.0"

  #Helm chart deployment can sometimes take longer than the default 5 minutes
  timeout = 1600

  # If values file specified by the var.values_file input variable exists then apply the values from this file
  # else apply the default values from the chart
  values = [templatefile(
          "${path.module}/templates/argocd-values.yaml.tpl", {
          argocd_ingress_enabled           = var.argocd_ingress_enabled
          argocd_annotations               =  { "kubernetes.io/ingress.class" = "alb"
                                                "alb.ingress.kubernetes.io/scheme" = "internet-facing"
                                                "alb.ingress.kubernetes.io/target-type" = "ip"
                                                "alb.ingress.kubernetes.io/certificate-arn" = "${var.acm_certificate_arn}"
                                                "alb.ingress.kubernetes.io/ssl-redirect" = "443"
                                                "alb.ingress.kubernetes.io/listen-ports" = "'[{\"HTTP\": 80}, {\"HTTPS\":443}]'"
                                                "alb.ingress.kubernetes.io/group.name" = "ds-alb"
                                                #"alb.ingress.kubernetes.io/security-groups" =  join(",", var.ingress_alb_security_groups)
                                                "alb.ingress.kubernetes.io/tags" =  "Environment=dev,mlops-platform=k8s-argo-kubeflow"
                                              }
          argocd_server_host                = var.argocd_server_host
      })]

  # set_sensitive {
  #   name  = "configs.secret.argocdServerAdminPassword"
  #   value = "admin"
  # }

  set {
    name  = "server.extraArgs"
    value = var.insecure == false ? "" : "{--insecure}"
  }

  set {
    name  = "dex.enabled"
    value = var.enable_dex == true ? true : false
  }
}