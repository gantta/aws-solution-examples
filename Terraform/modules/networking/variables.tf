variable "tags" {
  type        = map(string)
  description = "Collection of tags passed from calling module"
}

variable "region" {
  type = string
  description = "Primary region for all resources"
}


variable "region_number" {
  # Arbitrary mapping of region name to number to use in
  # a VPC's CIDR prefix.
  default = {
    us-east-1      = 1
    us-east-2      = 2
    us-west-1      = 3
    us-west-2      = 4
    eu-central-1   = 5
    ap-northeast-1 = 6
  }
}

variable "az_number" {
  # Assign a number to each AZ letter used in our configuration
  default = {
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
    f = 6
    # and so on, up to n = 14 if that many letters are assigned
  }
}
