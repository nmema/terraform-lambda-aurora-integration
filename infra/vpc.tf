module "vpc" {
  source = "git::https://github.com/nmema/terraform-baby-modules.git//services/vpc?ref=v0.0.4"

  aws_region = var.aws_region

  vpc_cidr              = var.vpc_cidr
  public_subnets_cidrs  = var.public_subnets_cidrs
  private_subnets_cidrs = var.private_subnets_cidrs
  azs                   = var.azs

  prefix_name        = "Integration"
  enable_nat_gateway = false
}
