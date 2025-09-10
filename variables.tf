variable "nrn" {
  type = string
}

variable "github_organization" {
  type = string
}

variable "github_organization_installation_id" {
  type = string
}
variable "domain_name" {
  type = string
}
variable "organization" {
  type        = string
  description = "value"
}
variable "account" {
  type        = string
  description = "A account name"
}
variable "vpc_id" {
  type        = string
  description = "A account name"
}
variable "aws_region" {
  type = string
}
variable "environment" {
  type = string
}
variable "cluster_name" {
  type = string
}

variable "api_key" {
  type = string
}

variable "include_environment" {
  type = bool
}

variable "agent_repos" {}
variable "tags" {}
variable "vpc" {}