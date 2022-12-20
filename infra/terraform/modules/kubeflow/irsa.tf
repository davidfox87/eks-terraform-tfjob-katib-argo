

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "kubeflow_iam_profile_controller"
  provider_url                  = replace("${var.eks_cluster_oidc_issuer}", "https://", "")
  role_policy_arns              = [aws_iam_policy.iam_profile_controller_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kubeflow:${local.k8s_service_account_name}"]

  tags = {
    Role = "role-with-oidc for kubeflow katib"
  }
}

resource "aws_iam_policy" "iam_profile_controller_policy" {
  name_prefix = "kubeflow-"
  description = "iam profile controller policy for kubeflow"
  policy      = data.aws_iam_policy_document.iam_profile_controller_policy_document.json
}

data "aws_iam_policy_document" "iam_profile_controller_policy_document" {
  version = "2012-10-17"
  statement {
    sid = "VisualEditor0"
    effect = "Allow"
    actions = [ "iam:GetRole",
                "iam:UpdateAssumeRolePolicy"
    ]
    resources = [ "*" ]
  }
}


# finish off referring to
# https://awslabs.github.io/kubeflow-manifests/docs/component-guides/profiles/#configuration-steps