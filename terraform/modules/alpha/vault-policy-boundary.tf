# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy#example-usage
resource "vault_policy" "boundary_default" {
  name = "boundary-default"

  policy = <<EOT
# https://developer.hashicorp.com/vault/tutorials/auth-methods/oidc-identity-provider#policy-requirements
# To create an entity and entity alias. Enable and configure Vault as an OIDC provider
path "identity/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# To enable userpass auth method
path "sys/auth/userpass" {
  capabilities = [ "create", "read", "update", "delete" ]
}

# To create a new user, "end-user" for userpass
path "auth/userpass/users/*" {
   capabilities = [ "create", "read", "update", "delete", "list" ]
}

EOT
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy#example-usage
resource "vault_policy" "boundary_transit" {
  name = "boundary-transit"

  policy = <<EOT
# https://developer.hashicorp.com/boundary/docs/configuration/kms/transit#authentication
# To create a KMS for Boundary
path "${vault_mount.transit.path}/encrypt/${vault_transit_secret_backend_key.key.name}" {
  capabilities = ["update"]
}

path "${vault_mount.transit.path}/decrypt/${vault_transit_secret_backend_key.key.name}" {
  capabilities = ["update"]
}

EOT
}

