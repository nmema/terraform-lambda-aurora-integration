terraform {
  backend "s3" {
    key = "lambda-aurora-integration/terraform.tfstate"
  }
}
