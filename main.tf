###############################################################################
# VPC Config
################################################################################
module "foundations_vpc" {
  source       = "git@github.com:nullplatform/tofu-modules.git//infrastructure/aws/vpc?ref=feature/refactor-scope-agents"
  account      = var.account
  organization = var.organization
  vpc          = var.vpc
}

###############################################################################
# EKS Config
################################################################################
module "foundations_eks" {
  source                  = "git@github.com:nullplatform/tofu-modules.git//infrastructure/aws/eks?ref=feature/refactor-scope-agents"
  aws_subnets_private_ids = module.foundations_vpc.private_subnets
  aws_vpc_vpc_id          = module.foundations_vpc.vpc_id
  name                    = var.cluster_name
}

###############################################################################
# DNS Config
################################################################################
module "foundations_dns" {
  source      = "git@github.com:nullplatform/tofu-modules.git//infrastructure/aws/route53?ref=feature/refactor-scope-agents"
  domain_name = var.domain_name
  vpc_id      = module.foundations_vpc.vpc_id
}

###############################################################################
# ALB Controller Config
################################################################################
module "foundations_alb_controller" {
  source = "git@github.com:nullplatform/tofu-modules.git//infrastructure/aws/alb_controller?ref=feature/refactor-scope-agents"

  aws_iam_openid_connect_provider = module.foundations_eks.eks_oidc_provider_arn
  cluster_name                    = module.foundations_eks.eks_cluster_name
  vpc_id                          = module.foundations_vpc.vpc_id

  depends_on = [module.foundations_eks]
}

###############################################################################
# Ingress Config
################################################################################
module "foundations_networking" {
  source = "git@github.com:nullplatform/tofu-modules.git//infrastructure/aws/ingress?ref=feature/refactor-scope-agents"

  certificate_arn = module.foundations_dns.acm_certificate_arn

  depends_on = [module.foundations_alb_controller]
}

###############################################################################
# Code Repository
################################################################################
module "nullplatform_code_repository" {
  source           = "git@github.com:nullplatform/tofu-modules.git//nullplatform/code_repository?ref=feature/refactor-scope-agents"
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
  source                 = "git@github.com:nullplatform/tofu-modules.git//nullplatform/cloud/aws/cloud?ref=feature/refactor-scope-agents"
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
  source     = "git@github.com:nullplatform/tofu-modules.git//nullplatform/asset/ecr?ref=feature/refactor-scope-agents"
  nrn        = var.nrn
  np_api_key = var.np_api_key
}

###############################################################################
# Dimensions
################################################################################
module "nullplatform_dimension" {
  source     = "git@github.com:nullplatform/tofu-modules.git//nullplatform/dimensions?ref=feature/refactor-scope-agents"
  np_api_key = var.np_api_key
  nrn        = var.nrn
}




###############################################################################
# Nullplatform Base
################################################################################
module "nullplatform_base" {
  source = "git@github.com:nullplatform/tofu-modules.git//nullplatform/cloud/aws/base?ref=feature/refactor-scope-agents"
  nrn    = var.nrn

  depends_on = [module.foundations_eks]
}


###############################################################################
# Prometheus Config
################################################################################
module "nullplatform_prometheus" {
  source     = "git@github.com:nullplatform/tofu-modules.git//nullplatform/prometheus?ref=feature/refactor-scope-agents"
  np_api_key = var.np_api_key
  nrn        = var.nrn

}

module "nullplatform_scope_agent" {
  source = "git@github.com:nullplatform/tofu-modules.git//nullplatform/cloud/aws/agent?ref=feature/refactor-scope-agents"

  aws_iam_openid_connect_provider_arn = module.foundations_eks.eks_oidc_provider_arn
  cluster_name                        = module.foundations_eks.eks_cluster_name
  np_api_key                          = var.np_api_key
  nrn                                 = var.nrn
  tags_selectors                      = var.tag_selectors
  service_spec_name                   = "AgentScope"
  service_spec_description            = "Deployments using agent scopes"

}