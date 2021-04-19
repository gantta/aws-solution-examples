variable "zone_name" {
  type = string
  default = ""
  description = "Domain name"
}

variable "amplify_url" {
  type = string
  default = ""
  description = "The URL to the Amplify "
}

variable "tags" {
  type        = map(string)
  description = "Collection of tags passed from calling module"
}
