terraform {
  # Set minimum required versions for providers using lazy matching
  required_version = "~> 1.9.7"

  # Configure the S3 backend
  backend "s3" {
    bucket = "s3-esp-shared-terraform-state"
    key    = "terraform.tfstate"
    region = "ap-northeast-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.70.0"
    }
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = ">= 2.7"
    # }
    # kubectl = {
    #   source  = "alekc/kubectl"
    #   version = ">= 2.0"
    # }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.4"
    }
  }
}

provider "aws" {
  region = local.region
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

# provider "helm" {
#   kubernetes {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "aws"
#       # This requires the awscli to be installed locally where Terraform is executed
#       args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#     }
#   }
# }

# provider "kubectl" {
#   apply_retry_count      = 5
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   load_config_file       = false

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     # This requires the awscli to be installed locally where Terraform is executed
#     args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
# }
