terraform {
  required_version = ">= 1.8"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.94.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
 /* 
  backend "s3" {
    bucket         = "terraform-state-bucket-alb-waf"
    key            = "alb-waf/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }*/
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      # Tags existants
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
      
      # Tags pour la sécurité et la conformité
      SecurityCompliance = "PCI-DSS"
      DataClassification = "Internal"
      
      # Tags pour la gestion des coûts
      CostCenter   = "Infrastructure"
      BusinessUnit = "IT"
      
      # Tags pour l'automatisation
      AutoShutdown = var.environment == "Development" ? "true" : "false"
      BackupPolicy = var.environment == "Production" ? "Daily" : "Weekly"
      
      # Tags supplémentaires
      Owner        = "InfraTeam"
      Application  = "ALB-WAF-Demo"
      Tier         = var.environment == "Production" ? "Production" : "Non-Production"
      CreatedBy    = "Terraform"
      CreatedDate  = "2025-05-05"
    }
  }
}

provider "random" {}