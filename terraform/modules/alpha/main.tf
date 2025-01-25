terraform {
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/boundary/latest/docs/resources/target#example-usage
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.2.0"
    }
    # https://registry.terraform.io/providers/hashicorp/nomad/latest/docs#example-usage
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.4.0"
    }
    # https://registry.terraform.io/providers/hashicorp/tfe/latest/docs#example-usage
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.62.0"
    }
    # https://registry.terraform.io/providers/hashicorp/vault/latest/docs#example-usage
    vault = {
      source  = "hashicorp/vault"
      version = "4.5.0"
    }
  }
}