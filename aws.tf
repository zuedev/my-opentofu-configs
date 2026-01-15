provider "aws" {
  region = "eu-west-2"
}

# S3 bucket for OpenTofu state files
resource "aws_s3_bucket" "zuedev-opentofu-state" {
  bucket = "zuedev-opentofu-state"
}

# Enable versioning on the OpenTofu state S3 bucket
resource "aws_s3_bucket_versioning" "zuedev-opentofu-state" {
  bucket = aws_s3_bucket.zuedev-opentofu-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Route 53 hosted zone for opentofu.aws.zue.dev
# Parent zone (zue.dev) must delegate to this zone via NS records after creation
# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-routing-traffic-for-subdomains.html
resource "aws_route53_zone" "opentofu-dot-aws-dot-zue-dot-dev" {
  name = "opentofu.aws.zue.dev"
}