terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"
  cidr_block = "10.0.0.0/16"
}

module "eks" {
  source        = "./modules/eks"
  vpc_id        = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets
  cluster_name  = var.cluster_name
}

module "rds" {
  source         = "./modules/rds"
  vpc_id         = module.network.vpc_id
  private_subnets = module.network.private_subnets
  db_name        = var.db_name
  db_username    = var.db_user
  db_password    = var.db_password
}
