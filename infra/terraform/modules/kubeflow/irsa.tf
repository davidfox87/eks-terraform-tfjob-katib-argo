resource "aws_iam_policy" "kubeflow-profile-controller" {
  name        = "kubeflow-profile-controller"
  description = "Kubeflow profile controller"

  policy = file("${path.module}/iam_profile_controller_policy.json")
}


module "iam_assumable_role_kubeflow_profile_controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  
  version = "~> 4.0"

  create_role                   = true

  role_name                     = local.profile_name 
  provider_url                  = replace(var.iam-oidc-provider-url, "https://", "")
  provider_urls = [
    replace(var.iam-oidc-provider-url, "https://", "")
  ]

  role_policy_arns              = [
    aws_iam_policy.kubeflow-profile-controller.arn,
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
  
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace_kubeflow}:${local.k8s_service_account_name_kubeflow}"]
  # oidc_fully_qualified_subjects = ["sts.amazon.com"]

  tags = {
    Role = "role-with-oidc"
  }
}

