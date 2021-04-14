data "aws_region" "current" {}

# Determine all of the available availability zones in the
# current AWS region.
data "aws_availability_zones" "available" {
  state = "available"
}

# This additional data source determines some additional
# details about each VPC, including its suffix letter.
data "aws_availability_zone" "all" {
  for_each = toset(data.aws_availability_zones.available.names)

  name = each.key
}

# A single VPC for the region
resource "aws_vpc" "main" {
  cidr_block           = cidrsubnet("10.1.0.0/16", 4, var.region_number[data.aws_region.current.name])
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = var.tags
}

# A subnet for each availability zone in the region.
resource "aws_subnet" "main" {
  for_each = data.aws_availability_zone.all

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, var.az_number[each.value.name_suffix])

  tags = var.tags
}