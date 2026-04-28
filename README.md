# Prerequisite

This Repo is to reproduce the behaviour described in https://github.com/gruntwork-io/terragrunt/issues/5986

You need a local machine with platform `darwin_arm64`

## Setup

Build 2 images, one with working version of `Teragrunt` and one non-working one.

### Build images

```shell
docker build --build-arg TERRAGRUNT_VERSION=0.99.5 -t tg-tofu:0.99.5 .
```

```shell
docker build --build-arg TERRAGRUNT_VERSION=1.0.3 -t tg-tofu:1.0.3 .
```

### Create lockfile (optional)

Either use the provided on (generated on macOS) or create your own.

Note: make sure they only contgain one `h1` line (the amr64 one)

If you want to create your own (this is not inside the images, run commands locally):

```text
# just as reference:
$ uname -mo
arm64 Darwin
```

```shell
cd IaC/terragrunt/env
terragrunt run --all -- init -reconfigure
find . -type d -name '.terragrunt-cache' -depth -exec rm -r {} \;
```

## Reproduce issue

Now we simulate processes on the Linux CI/CD server.

### Terragrunt 0.99.5

```shell
# be in repo root
docker run --rm -it --platform linux/amd64 -v $(pwd)/IaC:/workspace -w /workspace localhost/tg-tofu:0.99.5 bash

# inside container
terragrunt -version
TG_PROVIDER_CACHE_DIR=$(mktemp --directory)
TG_PROVIDER_CACHE=1
export TG_PROVIDER_CACHE TG_PROVIDER_CACHE_DIR 
cd terragrunt/env/A/
terragrunt run --all -- plan
```

The result should look like:

```text
terragrunt version v0.99.5
14:57:19.036 INFO   Terragrunt Cache server is listening on 127.0.0.1:39859
14:57:19.038 INFO   Start Terragrunt Cache server
14:57:19.069 INFO   Unit queue will be processed for plan in this order:
- Unit my-module

14:57:19.078 INFO   [my-module] Downloading Terraform configurations from ../../../tf_module into ./my-module/.terragrunt-cache/pbbf3n8kfS3lfQ2bHgzas9rMPUM/9raDj5UIo4uWr83CBgtrkSytnyg
14:57:19.214 INFO   [my-module] Caching terraform providers for ./my-module/.terragrunt-cache/pbbf3n8kfS3lfQ2bHgzas9rMPUM/9raDj5UIo4uWr83CBgtrkSytnyg
14:57:20.107 INFO   Cached registry.opentofu.org/hashicorp/random v3.8.1 (self-signed)
14:57:20.339 INFO   [my-module] tofu: Initializing the backend...
14:57:20.356 INFO   [my-module] tofu: Initializing provider plugins...
14:57:20.357 INFO   [my-module] tofu: - Reusing previous version of hashicorp/random from the dependency lock file
14:57:20.369 INFO   [my-module] tofu: - Installing hashicorp/random v3.8.1...
14:57:20.480 INFO   [my-module] tofu: - Installed hashicorp/random v3.8.1 (unauthenticated)
14:57:20.480 INFO   [my-module] tofu: OpenTofu has been successfully initialized!
14:57:20.480 INFO   [my-module] tofu: 
14:57:20.480 INFO   [my-module] tofu: You may now begin working with OpenTofu. Try running "tofu plan" to see
14:57:20.480 INFO   [my-module] tofu: any changes that are required for your infrastructure. All OpenTofu commands
14:57:20.480 INFO   [my-module] tofu: should now work.
14:57:20.480 INFO   [my-module] tofu: If you ever set or change modules or backend configuration for OpenTofu,
14:57:20.480 INFO   [my-module] tofu: rerun this command to reinitialize your working directory. If you forget, other
14:57:20.480 INFO   [my-module] tofu: commands will detect it and remind you to do so if necessary.
14:57:21.197 STDOUT [my-module] tofu: OpenTofu used the selected providers to generate the following execution
14:57:21.197 STDOUT [my-module] tofu: plan. Resource actions are indicated with the following symbols:
14:57:21.197 STDOUT [my-module] tofu:   + create
14:57:21.197 STDOUT [my-module] tofu: OpenTofu will perform the following actions:
14:57:21.198 STDOUT [my-module] tofu:   # random_id.this will be created
14:57:21.198 STDOUT [my-module] tofu:   + resource "random_id" "this" {
14:57:21.198 STDOUT [my-module] tofu:       + b64_std     = (known after apply)
14:57:21.198 STDOUT [my-module] tofu:       + b64_url     = (known after apply)
14:57:21.198 STDOUT [my-module] tofu:       + byte_length = 8
14:57:21.198 STDOUT [my-module] tofu:       + dec         = (known after apply)
14:57:21.198 STDOUT [my-module] tofu:       + hex         = (known after apply)
14:57:21.198 STDOUT [my-module] tofu:       + id          = (known after apply)
14:57:21.198 STDOUT [my-module] tofu:     }
14:57:21.198 STDOUT [my-module] tofu: Plan: 1 to add, 0 to change, 0 to destroy.
14:57:21.198 STDOUT [my-module] tofu: 
14:57:21.198 STDOUT [my-module] tofu: Changes to Outputs:
14:57:21.198 STDOUT [my-module] tofu:   + id = (known after apply)
14:57:21.198 STDOUT [my-module] tofu: 
14:57:21.198 STDOUT [my-module] tofu: ─────────────────────────────────────────────────────────────────────────────
14:57:21.199 STDOUT [my-module] tofu: Note: You didn't use the -out option to save this plan, so OpenTofu can't
14:57:21.199 STDOUT [my-module] tofu: guarantee to take exactly these actions if you run "tofu apply" now.

❯❯ Run Summary  1 units  2s
   ────────────────────────────
   Succeeded    1

14:57:21.203 INFO   Shutting down Terragrunt Cache server...
14:57:21.203 INFO   Terragrunt Cache server stopped
```

### Terragrunt 1.0.3

```shell
# be in repo root
docker run --rm -it --platform linux/amd64 -v $(pwd)/IaC:/workspace -w /workspace localhost/tg-tofu:1.0.3 bash

# inside container
terragrunt -version
TG_PROVIDER_CACHE_DIR=$(mktemp --directory)
TG_PROVIDER_CACHE=1
export TG_PROVIDER_CACHE TG_PROVIDER_CACHE_DIR 
cd terragrunt/env/B/
terragrunt run --all -- plan
```

The result should look like:

```text
terragrunt version v1.0.3
14:59:03.429 INFO   Terragrunt Cache server is listening on 127.0.0.1:38137
14:59:03.431 INFO   Start Terragrunt Cache server
14:59:03.464 INFO   - Unit my-module

14:59:03.475 INFO   [my-module] Downloading Terraform configurations from ../../../tf_module into ./my-module/.terragrunt-cache/Kp306wI7DJxC9YmhX2gUHhnRhxE/9raDj5UIo4uWr83CBgtrkSytnyg
14:59:04.005 INFO   [my-module] Caching terraform providers for /workspace/terragrunt/env/B/my-module/.terragrunt-cache/Kp306wI7DJxC9YmhX2gUHhnRhxE/9raDj5UIo4uWr83CBgtrkSytnyg
14:59:04.854 INFO   Cached registry.opentofu.org/hashicorp/random v3.8.1 (self-signed)
14:59:05.050 INFO   [my-module] tofu: Initializing the backend...
14:59:05.065 INFO   [my-module] tofu: Initializing provider plugins...
14:59:05.066 INFO   [my-module] tofu: - Reusing previous version of hashicorp/random from the dependency lock file
14:59:05.080 INFO   [my-module] tofu: - Installing hashicorp/random v3.8.1...
14:59:05.139 ERROR  [my-module] tofu: ╷
14:59:05.139 ERROR  [my-module] tofu: │ Error: Failed to install provider
14:59:05.139 ERROR  [my-module] tofu: │ 
14:59:05.139 ERROR  [my-module] tofu: │ Error while installing hashicorp/random v3.8.1: the local package for
14:59:05.139 ERROR  [my-module] tofu: │ registry.opentofu.org/hashicorp/random 3.8.1 doesn't match any of the
14:59:05.139 ERROR  [my-module] tofu: │ checksums previously recorded in the dependency lock file (this might be
14:59:05.139 ERROR  [my-module] tofu: │ because the available checksums are for packages targeting different
14:59:05.139 ERROR  [my-module] tofu: │ platforms); for more information:
14:59:05.139 ERROR  [my-module] tofu: │ https://opentofu.org/docs/language/files/dependency-lock/#checksum-verification
14:59:05.139 ERROR  [my-module] tofu: ╵
14:59:05.139 ERROR  [my-module] tofu: 
14:59:05.144 ERROR  Run failed: error occurred:

* Failed to execute "tofu init" in ./my-module/.terragrunt-cache/Kp306wI7DJxC9YmhX2gUHhnRhxE/9raDj5UIo4uWr83CBgtrkSytnyg
  ╷
  │ Error: Failed to install provider
  │ 
  │ Error while installing hashicorp/random v3.8.1: the local package for
  │ registry.opentofu.org/hashicorp/random 3.8.1 doesn't match any of the
  │ checksums previously recorded in the dependency lock file (this might be
  │ because the available checksums are for packages targeting different
  │ platforms); for more information:
  │ https://opentofu.org/docs/language/files/dependency-lock/#checksum-verification
  ╵
  
  
  exit status 1


❯❯ Run Summary  1 units  1s
   ────────────────────────────
   Failed       1

14:59:05.144 INFO   Shutting down Terragrunt Cache server...
14:59:05.145 INFO   Terragrunt Cache server stopped
14:59:05.145 INFO   TIP (debugging-docs): For help troubleshooting errors, visit https://docs.terragrunt.com/troubleshooting/debugging
14:59:05.145 ERROR  error occurred:

* Failed to execute "tofu init" in ./my-module/.terragrunt-cache/Kp306wI7DJxC9YmhX2gUHhnRhxE/9raDj5UIo4uWr83CBgtrkSytnyg
  ╷
  │ Error: Failed to install provider
  │ 
  │ Error while installing hashicorp/random v3.8.1: the local package for
  │ registry.opentofu.org/hashicorp/random 3.8.1 doesn't match any of the
  │ checksums previously recorded in the dependency lock file (this might be
  │ because the available checksums are for packages targeting different
  │ platforms); for more information:
  │ https://opentofu.org/docs/language/files/dependency-lock/#checksum-verification
  ╵
  
  
  exit status 1
```
