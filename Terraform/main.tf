locals {
  tier = {
    web   = "web"
    app   = "app"
    data  = "rds"
    tools = "tools"
  }
  product_tags = {
    Name          = var.prefix
    Environment   = var.environment
    Project       = var.prefix
    rebootAllowed = 1
  }
}

resource "aws_resourcegroups_group" "main" {
  name = "${var.prefix}-rg"
  description = "Resources for the ${var.prefix} project"
  resource_query {
    type  = "TAG_FILTERS_1_0"
    query = <<JSON
{
  "ResourceTypeFilters": [
     "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "Project",
      "Values": ["${var.prefix}"]
    }
  ]
}
JSON
  }

  tags = var.tags
}

module "networking" {
  source = "./modules/networking"
  region = var.region
  tags   = local.product_tags
}