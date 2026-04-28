locals {
  module_path = "${path_relative_to_include()}"
}

remote_state {
  backend = "local"
  config = {
    path = "${get_parent_terragrunt_dir()}/.terraform-state/${local.module_path}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}
