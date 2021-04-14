# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline
resource "aws_codepipeline" "default" {
  name     = var.name
  role_arn = aws_iam_role.default.arn

  # The Amazon S3 bucket where artifacts are stored for the pipeline.
  # https://docs.aws.amazon.com/codepipeline/latest/APIReference/API_ArtifactStore.html
  artifact_store {
    # A folder to contain the pipeline artifacts is created for you based on the name of the pipeline.
    # You can use any Amazon S3 bucket in the same AWS Region as the pipeline to store your pipeline artifacts.
    location = aws_s3_bucket.pipeline_bucket.bucket

    # The value must be set to S3.
    type = "S3"

    # The encryption key used to encrypt the data in the artifact store, such as an AWS KMS key.
    # If this is undefined, the default key for Amazon S3 is used.
  }

  # The pipeline structure has the following requirements:
  #
  # - A pipeline must contain at least two stages.
  # - The first stage of a pipeline must contain at least one source action, and can only contain source actions.
  # - Only the first stage of a pipeline may contain source actions.
  # - At least one stage in each pipeline must contain an action that is not a source action.
  # - All stage names within a pipeline must be unique.
  #
  # https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = 1
      run_order        = 1
      output_artifacts = ["Source"]

      configuration = {
        Owner  = var.repository_owner
        Repo   = var.repository_name
        Branch = var.branch

        # The token require the following GitHub scopes:
        #
        # - The repo scope, which is used for full control to read and pull artifacts from public and private repositories into a pipeline.
        # - The admin:repo_hook scope, which is used for full control of repository hooks.
        #
        # Create a personal access token on your application settings page of GitHub.
        # https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/
        #
        # NOTE: github_oauth_token may show up in logs, and it will be stored in the raw state as plain-text.
        OAuthToken = var.github_oauth_token

        # Pipelines start automatically when repository changes are detected. One change detection method is
        # periodic checks. Periodic checks can be enabled or disabled using the PollForSourceChanges flag.
        # https://docs.aws.amazon.com/codepipeline/latest/userguide/run-automatically-polling.html
        PollForSourceChanges = var.poll_for_source_changes
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      run_order        = 1
      input_artifacts  = ["Source"]
      output_artifacts = ["Build"]

      configuration = {
        ProjectName = aws_codebuild_project.default.name

        # One of your input sources must be designated the PrimarySource. This source is the directory
        # where AWS CodeBuild looks for and runs your buildspec file. The keyword PrimarySource is used to
        # specify the primary source in the configuration section of the CodeBuild stage in the JSON file.
        # https://docs.aws.amazon.com/codebuild/latest/userguide/sample-pipeline-multi-input-output.html
        PrimarySource = "Source"
      }
    }
  }

  # Suppress that Github OAuth causing persistent changes.
  # https://github.com/terraform-providers/terraform-provider-aws/issues/2854
  lifecycle {
    ignore_changes = [
      stage.0.action.0.configuration.OAuthToken
    ]
  }

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "${var.name}-pipeline"
  acl    = "private"

  tags = var.tags
}

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

# Webhook for GitHub Pipeline
#
# https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-webhooks.html

# https://www.terraform.io/docs/providers/aws/r/codepipeline_webhook.html
resource "aws_codepipeline_webhook" "default" {
  name            = aws_codepipeline.default.name
  target_pipeline = aws_codepipeline.default.name

  # The name of the action in a pipeline you want to connect to the webhook.
  # The action must be from the source (first) stage of the pipeline.
  target_action = "Source"

  # GITHUB_HMAC implements the authentication scheme described here: https://developer.github.com/webhooks/securing/
  # https://docs.aws.amazon.com/codepipeline/latest/APIReference/API_WebhookDefinition.html#CodePipeline-Type-WebhookDefinition-authentication
  authentication = "GITHUB_HMAC"

  # Set the same value as Secret of GitHub.
  #
  # NOTE: This value will be a random character string consisting of 96 numeric characters
  #       when you setup from the AWS Management Console.
  #
  # https://docs.aws.amazon.com/codepipeline/latest/APIReference/API_WebhookAuthConfiguration.html
  authentication_configuration {
    secret_token = local.secret_token
  }

  # The event criteria that specify when a webhook notification is sent to your URL.
  # https://docs.aws.amazon.com/codepipeline/latest/APIReference/API_WebhookFilterRule.html
  filter {
    json_path    = var.filter_json_path
    match_equals = var.filter_match_equals
  }
}

# https://www.terraform.io/docs/providers/random/r/id.html
resource "random_id" "secret_token" {
  keepers = {
    keeper = var.name
  }

  byte_length = 40
}

locals {
  secret_token = var.secret_token == "" ? random_id.secret_token.dec : var.secret_token
}

# CodePipeline Service Role
#
# https://docs.aws.amazon.com/codepipeline/latest/userguide/how-to-custom-role.html

# https://www.terraform.io/docs/providers/aws/r/iam_role.html
resource "aws_iam_role" "default" {
  name               = local.iam_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  path               = var.iam_path
  description        = "Role for ${var.name} pipeline"
  tags               = var.tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "codepipeline.amazonaws.com",
        "s3.amazonaws.com",
        "codebuild.amazonaws.com"
      ]
    }
  }
}

# https://www.terraform.io/docs/providers/aws/r/iam_policy.html
resource "aws_iam_policy" "default" {
  name        = local.iam_name
  policy      = data.aws_iam_policy_document.policy.json
  path        = var.iam_path
  description = "Policy for ${aws_codepipeline.default.name}"
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
    ]

    resources = [
      aws_s3_bucket.pipeline_bucket.arn,
      "${aws_s3_bucket.pipeline_bucket.arn}/*",
      "arn:aws:s3:::gantta-terraform",
      "arn:aws:s3:::gantta-terraform/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "iam:PassRole"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "*"
    ]

    resources = ["*"]
  }
}

# https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html
resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}

locals {
  iam_name = "${var.name}-codepipeline"
}

resource "aws_codebuild_project" "default" {
  name          = var.project_name
  description   = "CodeBuild for ${var.name}"
  build_timeout = 5
  service_role  = aws_iam_role.default.arn
  badge_enabled = true

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.pipeline_bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = "0.14.9"
    }

    environment_variable {
      name  = "ACCESS_KEY"
      value = var.AWS_ACCESS_KEY_ID
    }

    environment_variable {
      name  = "SECRET"
      value = var.AWS_SECRET_ACCESS_KEY
    }

    environment_variable {
      name  = "GITHUB_PAT"
      value = var.GITHUB_PAT
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/gantta/aws-solution-examples.git"
    git_clone_depth = 1
    buildspec       = "./Terraform/modules/code_pipeline/buildspec.yml"

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "master"

  tags = var.tags
}
