###############################################################################
# VPC Config
################################################################################
module "foundations_vpc" {
  source       = "git::https://github.com/nullplatform/tofu-modules.git//infrastructure/aws/vpc?ref=v1.0.0"
  account      = var.account
  organization = var.organization
  vpc          = var.vpc
}

###############################################################################
# EKS Config
################################################################################
module "foundations_eks" {
  source                  = "git::https://github.com/nullplatform/tofu-modules.git//infrastructure/aws/eks?ref=v1.1.4"
  aws_subnets_private_ids = module.foundations_vpc.private_subnets
  aws_vpc_vpc_id          = module.foundations_vpc.vpc_id
  name                    = var.cluster_name
}

###############################################################################
# DNS Config
################################################################################
module "foundations_dns" {
  source      = "git::https://github.com/nullplatform/tofu-modules.git//infrastructure/aws/route53?ref=v1.0.2"
  domain_name = var.domain_name
  vpc_id      = module.foundations_vpc.vpc_id
}

###############################################################################
# ALB Controller Config
################################################################################
module "foundations_alb_controller" {
  source = "git::https://github.com/nullplatform/tofu-modules.git//infrastructure/aws/alb_controller?ref=v1.0.0"

  aws_iam_openid_connect_provider = module.foundations_eks.eks_oidc_provider_arn
  cluster_name                    = module.foundations_eks.eks_cluster_name
  vpc_id                          = module.foundations_vpc.vpc_id

  depends_on = [module.foundations_eks]
}

###############################################################################
# Ingress Config
################################################################################
module "foundations_networking" {
  source = "git::https://github.com/nullplatform/tofu-modules.git//infrastructure/aws/ingress?ref=v1.0.0"

  certificate_arn = module.foundations_dns.acm_certificate_arn

  depends_on = [module.foundations_alb_controller]
}

###############################################################################
# Code Repository
################################################################################
module "nullplatform_code_repository" {
  source           = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/code_repository?ref=v1.0.2"
  np_api_key       = var.np_api_key
  nrn              = var.nrn
  git_provider     = "gitlab"
  group_path       = var.group_path
  access_token     = var.access_token
  installation_url = var.installation_url
  collaborators_config = var.collaborators_config
  gitlab_repository_prefix = var.gitlab_repository_prefix
  gitlab_slug = var.gitlab_slug
}

###############################################################################
# Cloud Providers Config
################################################################################
module "nullplatform_cloud_provider" {
  source                 = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/cloud/aws/cloud?ref=v1.0.0"
  domain_name            = var.domain_name
  hosted_private_zone_id = module.foundations_dns.private_zone_id
  hosted_public_zone_id  = module.foundations_dns.public_zone_id
  np_api_key             = var.np_api_key
  nrn                    = var.nrn
}

###############################################################################
# Asset Repository
################################################################################
module "nullplatform_asset_respository" {
  source     = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/asset/ecr?ref=v1.1.4"
  nrn        = var.nrn
  np_api_key = var.np_api_key
}

###############################################################################
# Dimensions
################################################################################
module "nullplatform_dimension" {
  source     = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/dimensions?ref=v1.0.0"
  np_api_key = var.np_api_key
  nrn        = var.nrn
}

###############################################################################
# Nullplatform Base
################################################################################
module "nullplatform_base" {
  source = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/cloud/aws/base?ref=v1.0.0"
  nrn    = var.nrn

  depends_on = [module.foundations_eks]
}


###############################################################################
# Prometheus Config
################################################################################
module "nullplatform_prometheus" {
  source     = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/prometheus?ref=v1.0.0"
  np_api_key = var.np_api_key
  nrn        = var.nrn

}

module "nullplatform_scope_agent" {
  source = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/cloud/aws/agent?ref=v1.1.4"

  aws_iam_openid_connect_provider_arn = module.foundations_eks.eks_oidc_provider_arn
  cluster_name                        = module.foundations_eks.eks_cluster_name
  np_api_key                          = var.np_api_key
  nrn                                 = var.nrn
  tags_selectors                      = var.tag_selectors
}