# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/mount#example-usage
resource "vault_mount" "userpass" {
  path        = "userpass"
  type        = "kv"
  description = "KV Secrets Engine for Foo's UserPass creds"

  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/auth_backend#example-usage
resource "vault_auth_backend" "userpass" {
  type        = "userpass"
  description = "Auth Engine for Foo's UserPass creds"
  tune {
    max_lease_ttl      = "90000s"
    listing_visibility = "unauth"
  }
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret#example-usage
resource "vault_kv_secret" "userpass" {
  for_each = var.users
  path     = "auth/${vault_auth_backend.userpass.path}/users/${each.key}"
  data_json = jsonencode(
    {
      password = "${each.key}"
    }
  )
}