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

# SES domain identity for opentofu.aws.zue.dev
resource "aws_ses_domain_identity" "opentofu-dot-aws-dot-zue-dot-dev" {
  domain = aws_route53_zone.opentofu-dot-aws-dot-zue-dot-dev.name
}

# SES domain DKIM for opentofu.aws.zue.dev
resource "aws_ses_domain_dkim" "opentofu-dot-aws-dot-zue-dot-dev" {
  domain = aws_ses_domain_identity.opentofu-dot-aws-dot-zue-dot-dev.domain
}

# Route 53 records for SES domain verification
resource "aws_route53_record" "opentofu-dot-aws-dot-zue-dot-dev-ses-verification" {
  count   = 3
  zone_id = aws_route53_zone.opentofu-dot-aws-dot-zue-dot-dev.zone_id
  name    = "${aws_ses_domain_dkim.opentofu-dot-aws-dot-zue-dot-dev.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.opentofu-dot-aws-dot-zue-dot-dev.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

# Route 53 record for SES DMARC
resource "aws_route53_record" "opentofu-dot-aws-dot-zue-dot-dev-ses-dmarc" {
  zone_id = aws_route53_zone.opentofu-dot-aws-dot-zue-dot-dev.zone_id
  name    = "_dmarc.${aws_route53_zone.opentofu-dot-aws-dot-zue-dot-dev.name}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1; p=none; rua=mailto:postmaster@zue.dev"]
}

# SES custom MAIL FROM domain
resource "aws_ses_domain_mail_from" "opentofu-dot-aws-dot-zue-dot-dev" {
  domain         = aws_ses_domain_identity.opentofu-dot-aws-dot-zue-dot-dev.domain
  mail_from_domain = "mail.${aws_route53_zone.opentofu-dot-aws-dot-zue-dot-dev.name}"
  behavior_on_mx_failure = "UseDefaultValue"
}

# Route 53 MX record for custom MAIL FROM domain
resource "aws_route53_record" "opentofu-dot-aws-dot-zue-dot-dev-mail-from-mx" {
  zone_id = aws_route53_zone.opentofu-dot-aws-dot-zue-dot-dev.zone_id
  name    = aws_ses_domain_mail_from.opentofu-dot-aws-dot-zue-dot-dev.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.eu-west-2.amazonses.com"]
}

# Route 53 SPF record for custom MAIL FROM domain
resource "aws_route53_record" "opentofu-dot-aws-dot-zue-dot-dev-mail-from-spf" {
  zone_id = aws_route53_zone.opentofu-dot-aws-dot-zue-dot-dev.zone_id
  name    = aws_ses_domain_mail_from.opentofu-dot-aws-dot-zue-dot-dev.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com ~all"]
}

# ses verified email identity for zuedev@gmail.com
resource "aws_ses_email_identity" "zuedev-gmail-com" {
  email = "zuedev@gmail.com"
  depends_on = [aws_ses_domain_identity.opentofu-dot-aws-dot-zue-dot-dev]
}