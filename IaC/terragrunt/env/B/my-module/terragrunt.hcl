include {
  path = find_in_parent_folders("root.hcl")
}

include "my-module" {
  path = "${path_relative_to_include()}/../../../tg_module/my-module.hcl"
}
