module "acm" {
  source = "terraform-aws-modules/acm/aws"

  domain_name         = "www.ibkaay.net"
  zone_id             = data.aws_route53_zone.main.zone_id
  validation_method   = "DNS"
  wait_for_validation = true
}
