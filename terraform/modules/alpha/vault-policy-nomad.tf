# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy#example-usage
resource "vault_policy" "nomad" {
  name = "nomad"

  policy = <<EOT
path "nomad/creds/nomad" {
  capabilities = ["read"]
}
EOT
}


resource "vault_policy" "nomad_server" {
  name = "nomad-server"

  policy = <<EOT
path "nomad/creds/nomad-server" {
  capabilities = ["read"]
}
EOT
}
