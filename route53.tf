resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${data.aws_route53_zone.main.name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.main_elb.dns_name]
}

data "aws_route53_zone" "main" {
  name = "ibkaay.net"
}
