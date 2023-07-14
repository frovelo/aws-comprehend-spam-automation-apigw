terraform {
  # required_version = ">= 1.3.0"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.30.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

data "aws_caller_identity" "main" {
}

locals {
  account_id                       = data.aws_caller_identity.main.account_id
  trusted_role_arn                 = "arn:aws:iam::012345678912:role/Admin"
  comprehend_endpoint_url          = "arn:aws:comprehend:us-east-1:012345678912:document-classifier-endpoint/prototype-spam-ham-endpoint"
  custom_classification_model_arn  = "arn:aws:comprehend:us-east-1:012345678912:document-classifier/prototype-spam-ham"
  custom_classification_model_name = "prototype-spam-ham"
}

module "us-east-1" {
  source = "./modules"

  account_id                       = local.account_id
  region                           = "us-east-1"
  trusted_role_arn                 = local.trusted_role_arn
  comprehend_endpoint_url          = local.comprehend_endpoint_url
  custom_classification_model_arn  = local.custom_classification_model_arn
  custom_classification_model_name = local.custom_classification_model_name
}
