resource "random_integer" "random" {
  min = 10000
  max = 99999
}

locals {
  common_tags = {
    name       = var.name
    value      = var.value
    environmet = terraform.workspace
  }
  name_prefix    = "${var.naming_prefix}-${terraform.workspace}"
  s3_bucket_name = lower("${local.name_prefix}-${random_integer.random.result}")
}