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
}
###############################################################################
#Prvider AWS
###############################################################################
module "cloud-provider" {
  source = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/nullplatform/providers/cloud/aws?ref=feature/add-null-config"
  account = var.account
  aws_region = var.aws_region
  domain_name = var.domain_name
  environment = var.environment
  hosted_public_zone_id = module.route53.public_zone_id
  hosted_private_zone_id = module.route53.private_zone_id
  nrn = var.nrn
  organization = var.organization
  scope_workflow_role = module.iam.nullplatform_scope_workflow_role_arn
}

################################################################################
# Route53 Module
################################################################################

module "route53" {
  source = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/aws/route53?ref=feature/add-null-config"
  account = var.account
  domain_name = var.domain_name
  environment = var.environment
  organization = var.organization
}

################################################################################
# IAM Module
################################################################################

module "iam" {
  source = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/aws/iam?ref=feature/add-null-config"
  account = var.account
  environment = var.environment
  organization = var.organization
}

###############################################################################
# AWS ALB Controller
################################################################################
module "aws_alb_controller" {
  source = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/aws/alb_controller?ref=feature/add-null-config"
  account = var.account
  cluster_name = var.cluster_name
  environment = var.environment
  organization = var.organization
  vpc_id = var.vpc_id
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
  source = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/nullplatform/helm/base?ref=feature/add-null-config"

}

###############################################################################
# Null Agent
################################################################################

module "null_agent" {
  source = "git::ssh://git@github.com/nullplatform/infrastructure-main-nullplatform-terraform.git//business/nullplatform/helm/agent?ref=feature/add-null-config"

  agent_repos  = ""
  cloud_name   = ""
  cluster_name = ""
  np_api_key   = ""
  tags         = ""
  vault_token  = ""
  vault_url    = ""
}
