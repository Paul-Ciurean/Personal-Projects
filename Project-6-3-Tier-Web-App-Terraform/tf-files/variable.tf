variable "vpc_cidr" {
  description = "The default CIDR for our subnet"
  default = "10.0.0.0/16"
}

variable "public_subnet" {
  description = "The default description for the public subnets"
  default = {
    "public_1" = 1
    "public_2" = 2

  }
}

variable "private_subnet_1" {
  description = "The default description for the private subnets"
  default = {
    "private_3" = 3
    "private_4" = 4
  }
}

variable "private_subnet_2" {
  description = "The default description for the private subnets"
  default = {
    "private_5" = 5
    "private_6" = 6
  }
}