terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

resource "random_id" "this" {
  byte_length = var.length
}

output "id" {
  value = random_id.this.hex
}

