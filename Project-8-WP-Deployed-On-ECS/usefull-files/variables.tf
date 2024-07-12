#################
# Provider vars #
#################

variable "region" {
  description = "Region to deploy resources"
  default     = "us-east-1"
}

#########################################
# Backend S3 bucket for state file vars #
#########################################

variable "bucket" {
  description = "Bucket name for state file"
  type        = string
}

###################
# Networking vars #
###################

variable "name" {
  description = "Resources name"
  type        = string
}

variable "cidr_vpc" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnets" {
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = [
    { name = "subnet-1", cidr = "10.0.1.0/24", az = "us-east-1a" },
    { name = "subnet-2", cidr = "10.0.2.0/24", az = "us-east-1b" },
  ]
}

variable "availability_zone" {
  description = "The value for AZ"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "internet-cidr" {
  description = "CIDR for internet access"
  type        = string
  default     = "0.0.0.0/0"
}

#################
# Database vars #
#################

variable "username" {
  description = "Chose a username for DB"
  type        = string
}

variable "password" {
  description = "Chose a password for DB"
  type        = string
}
