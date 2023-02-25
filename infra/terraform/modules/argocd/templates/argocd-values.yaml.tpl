installCRDs: false

server:
  ingress:
    enabled: ${ argocd_ingress_enabled }

    annotations:
        %{ for key, value in argocd_annotations }
        ${key}: ${value}
        %{ endfor ~}

        alb.ingress.kubernetes.io/security-groups: ${ ingress_alb_security_groups }

        alb.ingress.kubernetes.io/tags: ${ tags }


    hosts:
      - ${ argocd_server_host }
    paths:
      - /

