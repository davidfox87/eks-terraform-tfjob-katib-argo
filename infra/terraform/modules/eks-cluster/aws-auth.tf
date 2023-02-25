

locals {
    # concat function takes two or more lists and combines them into a single list
  map_roles = yamlencode(
    flatten(
        concat([{ rolearn  = "${aws_iam_role.workernodes.arn}"
                  username = "system:node:{{EC2PrivateDNSName}}"
                  groups = ["system:bootstrappers",
                            "system:nodes"
                  ]
            },
            var.map_additional_roles, 
      ])
    )
  )


  aws_auth_configmap_data = { 
    mapRoles = local.map_roles
    map_users    = yamlencode(var.map_users)
    map_accounts = yamlencode(var.map_accounts)
  }
}



# resource "kubernetes_config_map" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = local.aws_auth_configmap_data

#   lifecycle {
#     # We are ignoring the data here since we will manage it with the resource below
#     # This is only intended to be used in scenarios where the configmap does not exist
#     ignore_changes = [data, metadata[0].labels, metadata[0].annotations]
#   }
# }

resource "kubernetes_config_map_v1_data" "aws_auth" {
  force = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

#   depends_on = [
#     # Required for instances where the configmap does not exist yet to avoid race condition
#     kubernetes_config_map.aws_auth,
#   ]
}

