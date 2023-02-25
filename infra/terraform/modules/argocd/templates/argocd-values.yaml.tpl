installCRDs: false

server:
  ingress:
    enabled: ${ argocd_ingress_enabled }

    annotations:
        %{ for key, value in argocd_annotations }
        ${key}: ${value}
        %{ endfor ~}


    hosts:
      - ${ argocd_server_host }
    paths:
      - /

