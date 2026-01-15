terraform {
  backend "s3" {
    bucket       = "zuedev-opentofu-state"
    key          = "terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.10.0"
    }
  }
}