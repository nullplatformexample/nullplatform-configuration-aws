################################################################################
# Github Module
################################################################################

module "code-repository" {
  source = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/nullplatform/providers/code/github?ref=feature/add-null-config"
  nrn    = var.nrn

  organization                 = var.github_organization
  organization_installation_id = var.github_organization_installation_id
  account                      = var.account
  aws_region                   = var.aws_region
  environment                  = var.environment
  api_key                      = var.api_key
}
###############################################################################
#Prvider AWS
###############################################################################
module "cloud-provider" {
  source                 = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/nullplatform/providers/cloud/aws?ref=feature/add-null-config"
  account                = var.account
  aws_region             = var.aws_region
  domain_name            = var.domain_name
  environment            = var.environment
  hosted_public_zone_id  = module.route53.public_zone_id
  hosted_private_zone_id = module.route53.private_zone_id
  nrn                    = var.nrn
  organization           = var.organization
  scope_workflow_role    = module.iam.nullplatform_scope_workflow_role_arn
  api_key                = var.api_key
  include_environment    = var.include_environment
}

##############################################################################
#Prvider ECR
###############################################################################
module "asset-provider" {
  source                                = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/nullplatform/providers/asset/ecr?ref=feature/add-null-config"
  account                               = var.account
  api_key                               = var.api_key
  application_manager_role              = module.iam.nullplatform_application_role_arn
  aws_region                            = var.aws_region
  build_workflow_user_access_key_id     = module.iam.nullplatform_build_workflow_user_access_key_id
  build_workflow_user_secret_access_key = module.iam.nullplatform_build_workflow_user_secret_access_key
  environment                           = var.environment
  nrn                                   = var.nrn
  organization                          = var.organization
}

################################################################################
# Route53 Module
################################################################################

module "route53" {
  source       = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/aws/route53?ref=feature/add-null-config"
  account      = var.account
  domain_name  = var.domain_name
  environment  = var.environment
  organization = var.organization
  vpc_id       = var.vpc_id
}

################################################################################
# IAM Module
################################################################################

module "iam" {
  source       = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/aws/iam?ref=feature/add-null-config"
  account      = var.account
  environment  = var.environment
  organization = var.organization
}

###############################################################################
# AWS ALB Controller
################################################################################
module "aws_alb_controller" {
  source       = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/aws/alb_controller?ref=feature/add-null-config"
  account      = var.account
  cluster_name = var.cluster_name
  environment  = var.environment
  organization = var.organization
  vpc_id       = var.vpc_id
}

################################################################################
# ACM Module
################################################################################

module "acm" {
  source = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/aws/acm?ref=feature/add-null-config"

  account      = var.account
  domain_name  = var.domain_name
  environment  = var.environment
  organization = var.organization
  zone_id      = module.route53.public_zone_id
}

###############################################################################
#Helm Null Base
###############################################################################

module "base" {
  source             = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/nullplatform/helm/base?ref=feature/add-null-config"
  api_key            = var.api_key
  cluster_name       = var.cluster_name
  environment        = var.environment
  organization       = var.organization
  account            = var.account
  cloud              = "eks"
  prometheus_enabled = true
}

module "prometheus" {
  source               = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//workloads/prometheus?ref=feature/add-null-config"
  api_key              = var.api_key
  cluster_name         = var.cluster_name
}

###############################################################################
# Null Agent
################################################################################

module "null_agent" {
  source       = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/nullplatform/helm/agent?ref=feature/add-null-config"
  agent_repos = join(",", var.agent_repos)
  cloud_name   = "aws"
  cluster_name = var.cluster_name
  tags         = var.tags
  organization = var.organization
  environment = var.environment
  account = var.account
  api_key      = var.api_key
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//foundations/aws/vpc?ref=feature/add-null-config"
  account = var.account
  environment = var.environment
  organization = var.organization
  vpc = var.vpc
}

################################################################################
# EKS Cluster Module
################################################################################

module "eks" {
  source = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//cluster/eks?ref=feature/add-null-config"

  account         = var.account
  cluster_name    = var.cluster_name
  environment     = var.environment
  organization    = var.organization
  private_subnet_ids = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  scope_manager_role = module.iam.nullplatform_scope_workflow_role_arn
  telemetry_manager_role = module.iam.nullplatform_telemetry_manager_role_arn
}
