variable "name" {
  type        = string
  description = "The name of the pipeline."
}

variable "github_oauth_token" {
  type        = string
  sensitive   = true
  description = "The OAuth Token of GitHub."
}

variable "repository_owner" {
  type        = string
  description = "The owner of the repository."
}

variable "repository_name" {
  type        = string
  description = "The name of the repository."
}

variable "project_name" {
  type        = string
  description = "The project name of the CodeBuild."
}

variable "branch" {
  default     = "master"
  type        = string
  description = "The name of the branch."
}

variable "poll_for_source_changes" {
  default     = true
  type        = bool
  description = "Specify true to indicate that periodic checks enabled."
}

variable "secret_token" {
  default     = ""
  type        = string
  sensitive   = true
  description = "The secret token for the GitHub webhook."
}

variable "filter_json_path" {
  default     = "$.ref"
  type        = string
  description = "The JSON path to filter on."
}

variable "filter_match_equals" {
  default     = "refs/heads/{Branch}"
  type        = string
  description = "The value to match on (e.g. refs/heads/{Branch})."
}

variable "webhook_events" {
  default     = ["push"]
  type        = list(string)
  description = "A list of events which should trigger the webhook."
}

variable "tags" {
  type        = map(string)
  description = "Collection of tags passed from calling module"
}

variable "iam_path" {
  default     = "/"
  type        = string
  description = "Path in which to create the IAM Role and the IAM Policy."
}

variable "AWS_ACCESS_KEY_ID" {
  type = string
  sensitive = true
  default = ""
  description = "The AWS terraform user access key"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
  sensitive = true
  default = ""
  description = "The AWS terraform user secret key"
}

variable "GITHUB_PAT" {
  type = string
  sensitive = true
  default = ""
  description = "The Github personal access token for use in CodePipeline"
}
