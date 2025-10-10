###############################################################################
# VPC Config
################################################################################
module "foundations_vpc" {
  source       = "git::ssh://git@github.com/nullplatform/tofu-modules.git//infrastructure/aws/vpc?ref=feature/refactor-scope-agents"
  account      = var.account
  organization = var.organization
  vpc = var.vpc
}

###############################################################################
# EKS Config
################################################################################
module "foundations_eks" {
  source       = "git::ssh://git@github.com/nullplatform/tofu-modules.git//infrastructure/aws/eks?ref=feature/refactor-scope-agents"
  aws_subnets_private_ids = module.foundations_vpc.private_subnets
  aws_vpc_vpc_id = module.foundations_vpc.vpc_id
  name = var.cluster_name
}

###############################################################################
# ALB Controller Config
################################################################################
module "foundations_alb_controller" {
  source       = "git::ssh://git@github.com/nullplatform/tofu-modules.git//infrastructure/aws/alb_controller?ref=feature/refactor-scope-agents"

  aws_iam_openid_connect_provider = module.foundations_eks.eks_oidc_provider_arn
  cluster_name                    = module.foundations_eks.eks_cluster_name
  vpc_id                          = module.foundations_vpc.vpc_id
}

###############################################################################
# Ingress Config
################################################################################
module "foundations_networking" {
  source       = "git::ssh://git@github.com/nullplatform/tofu-modules.git//infrastructure/aws/ingress?ref=feature/refactor-scope-agents"
  certificate_arn = var.certificate_arn

  depends_on = [module.foundations_alb_controller]
}

###############################################################################
# Dimensions
################################################################################
module "nullplatform_dimension" {
  source       = "git::ssh://git@github.com/nullplatform/tofu-modules.git//nullplatform/dimensions?ref=feature/refactor-scope-agents"
  np_api_key   = var.np_api_key
  nrn          = var.nrn
}

###############################################################################
# Cloud Providers Config
################################################################################
module "nullplatform_provider_cloud" {
  source       = "git::ssh://git@github.com/nullplatform/tofu-modules.git//nullplatform/cloud/aws/cloud?ref=feature/refactor-scope-agents"
  domain_name  = var.domain_name
  hosted_private_zone_id = var.hosted_private_zone_id
  hosted_public_zone_id = var.hosted_public_zone_id
  np_api_key = var.np_api_key
  nrn = var.nrn
}

###############################################################################
# Prometheus Config
################################################################################
module "nullplatform_prometheus" {
  source       = "git::ssh://git@github.com/nullplatform/tofu-modules.git//nullplatform/prometheus?ref=feature/refactor-scope-agents"
  np_api_key   = var.np_api_key
  nrn          = var.nrn
}

###############################################################################
# Nullplatform Base
################################################################################
module "nullplatform_base" {
  source       = "git::ssh://git@github.com/nullplatform/tofu-modules.git//nullplatform/cloud/aws/base?ref=feature/refactor-scope-agents"
  nrn = var.nrn
}


###############################################################################
# Code Repository
################################################################################
module "nullplatform_code_repository" {
  source                       = "git::ssh://git@github.com/nullplatform/tofu-modules.git//nullplatform/code_repository?ref=feature/refactor-scope-agents"
  np_api_key                   = var.np_api_key
  nrn                          = var.nrn
  organization                 = var.github_organization
  organization_installation_id = var.github_installation_id
  git_provider                 = "github"
}

###############################################################################
# Asset Repository
################################################################################
module "nullplatform_asset_respository" {
  source                          = "git::ssh://git@github.com/nullplatform/tofu-modules.git//nullplatform/asset/ecr?ref=feature/refactor-scope-agents"
  nrn                             = var.nrn
  np_api_key                      = var.np_api_key
}



module "nullplatform_scope_agent" {
  source       = "git::ssh://git@github.com/nullplatform/tofu-modules.git//nullplatform/cloud/aws/agent?ref=feature/refactor-scope-agents"

  aws_iam_openid_connect_provider_arn = module.foundations_eks.eks_oidc_provider_arn
  cluster_name                        = module.foundations_eks.eks_cluster_name
  np_api_key                          = var.np_api_key
  nrn                                 = var.nrn
  tags_selectors                      = var.tag_selectors
  agent_repos_extra = var.agent_repos_extra
}