# Route 53 hosted zone for opentofu.aws.zue.dev
# Parent zone (zue.dev) must delegate to this zone via NS records after creation
# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-routing-traffic-for-subdomains.html
resource "aws_route53_zone" "opentofu-dot-aws-dot-zue-dot-dev" {
  name = "opentofu.aws.zue.dev"
}