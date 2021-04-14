variable "AWS_ACCESS_KEY_ID" {
  type = string
  default = ""
  description = "The AWS terraform user access key"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
  default = ""
  description = "The AWS terraform user secret key"
}

variable "environment" {
  type = string
  default = "dev"
  description = "Describes the environment tag for all resources"
}

variable "region" {
  type = string
  default = "us-east-2"
  description = "Primary region for all resources"
}

variable "prefix" {
  type = string
  default = "ganttaex"
  description = "Prefix to standardize naming conventions"
}

variable "tags" {
  description = "Default tags to add to resources"
  default = {
    "Key1": "Value"
  }
}