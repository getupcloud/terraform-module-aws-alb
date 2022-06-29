locals {
  name_prefix = substr("eks-alb-controller-${var.cluster_name}", 0, 32)
}

resource "aws_iam_policy" "alb" {
  name        = local.name_prefix
  description = "AWSLoadBalancerController policy for EKS cluster ${var.cluster_name}"
  policy      = file("${path.module}/policy.json")
}


module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.2"

  create_role                   = true
  role_name                     = local.name_prefix
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.alb.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"]
}
