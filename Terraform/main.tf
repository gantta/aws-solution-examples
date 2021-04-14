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
  }
}

module "code_pipeline" {
  source = "./modules/code_pipeline"
  name = local.product_tags.Project
  github_oauth_token = var.GITHUB_PAT
  repository_owner = "gantta"
  repository_name = "aws-solution-examples"
  project_name = local.product_tags.Project
  tags = local.product_tags
  AWS_ACCESS_KEY_ID = var.AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
  GITHUB_PAT = var.GITHUB_PAT
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