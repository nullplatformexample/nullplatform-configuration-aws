terraform {
  required_providers {
    nullplatform = {
      source  = "nullplatform/nullplatform"
      version = "~> 0.0.63"
    }
  }
}

provider "nullplatform" {
  api_key = var.np_api_key
}

provider "kubernetes" {
  host                   = module.foundations_eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.foundations_eks.eks_cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "--profile", "providers-test",
      "eks", "get-token",
      "--cluster-name", module.foundations_eks.eks_cluster_name
    ]
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.foundations_eks.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.foundations_eks.eks_cluster_ca)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "--profile", "providers-test",
        "eks", "get-token",
        "--cluster-name", module.foundations_eks.eks_cluster_name
      ]
    }
  }
}