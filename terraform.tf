terraform {
    required_version = ">= 1.0"

    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
      }
    }

    cloud {
      organization = "evoketechnologies"  # Create this in Terraform Cloud

      workspaces {
        name = "aws-sa-prod"
      }
    }
  }

  provider "aws" {
    region = var.aws_region
  }
