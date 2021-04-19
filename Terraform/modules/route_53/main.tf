resource "aws_route53_zone" "main" {
  name = var.zone_name
  comment = "Zone managed by Terraform"
  tags = var.tags
}
