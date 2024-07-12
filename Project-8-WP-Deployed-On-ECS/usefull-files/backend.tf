##########################
# Backend for state file #
##########################

terraform {
  backend "s3" {
    bucket = "bucket-name"
    key    = "state-file"
    region = "<region>"
  }
}
