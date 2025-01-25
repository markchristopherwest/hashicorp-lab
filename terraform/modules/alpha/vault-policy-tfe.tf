# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy#example-usage
resource "vault_policy" "tfe" {
  name = "tfe"

  policy = <<EOT
path "auth/token/lookup-accessor" {
  capabilities = ["update"]
}

path "auth/token/revoke-accessor" {
  capabilities = ["update"]
}
EOT
}