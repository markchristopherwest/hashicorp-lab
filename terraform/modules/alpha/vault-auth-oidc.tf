
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_oidc_assignment#example-usage
resource "vault_identity_oidc_assignment" "boundary" {
  name       = "my-assignment"
  entity_ids = [vault_identity_entity.boundary.id]
  group_ids  = [vault_identity_group.internal.id]
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_oidc_client#example-usage
resource "vault_identity_oidc_client" "boundary" {
  name = "boundary"
  redirect_uris = [
    "http://127.0.0.1:9200/v1/auth-methods/oidc:authenticate:callback",
    "http://boundary-0.vagrant:9200/v1/auth-methods/oidc:authenticate:callback",
    "http://localhost:9200/v1/auth-methods/oidc:authenticate:callback",
    "http://localhost:9210/v1/auth-methods/oidc:authenticate:callback",
    "http://192.168.56.110:9200/v1/auth-methods/oidc:authenticate:callback",
    "http://128.0.0.1:8200/ui/vault/identity/oidc/provider/my-provider/authorize",
    "http://localhost:8210/ui/vault/identity/oidc/provider/my-provider/authorize",
    "http://127.0.0.1:8251/callback",
    "http://127.0.0.1:8080/callback"
  ]
  assignments = [
    vault_identity_oidc_assignment.boundary.name
  ]
  key              = vault_identity_oidc_key.boundary.name
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/identity_oidc_client_creds#example-usage
data "vault_identity_oidc_client_creds" "boundary" {
  name = vault_identity_oidc_client.boundary.name
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_oidc_key#example-usage
resource "vault_identity_oidc_key" "boundary" {
  name             = "my-oidc-key-for-boundary"
  algorithm        = "RS256"
  rotation_period  = 3600
  verification_ttl = 3600

}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_oidc_role#example-usage
resource "vault_identity_oidc_role" "boundary" {
  name = "my-oidc-role-for-boundary"
  key  = vault_identity_oidc_key.boundary.name
  ttl  = 2400

}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_oidc_key_allowed_client_id#example-usage
resource "vault_identity_oidc_key_allowed_client_id" "boundary" {
  key_name          = vault_identity_oidc_key.boundary.name
  allowed_client_id = vault_identity_oidc_role.boundary.client_id
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_oidc_scope#example-usage
resource "vault_identity_oidc_scope" "groups" {
  name        = "groups"
  template    = <<EOT
{
    "groups": {{identity.entity.groups.names}}
}

EOT
  description = "Groups scope."
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_oidc_scope#example-usage
resource "vault_identity_oidc_scope" "user" {
  name     = "user"
  template = <<EOT
{
    "username": {{identity.entity.name}},
    "contact": {
        "email": {{identity.entity.metadata.email}},
        "phone_number": {{identity.entity.metadata.phone_number}}
    }
}

EOT


  description = "User scope."
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_oidc_provider#example-usage
resource "vault_identity_oidc_provider" "boundary" {
  name          = "my-oidc-provider-for-boundary"
  https_enabled = true
  # issuer_host = "127.0.0.1:8200"
  allowed_client_ids = [
    vault_identity_oidc_client.boundary.client_id
  ]
  scopes_supported = [
    vault_identity_oidc_scope.groups.name,
    vault_identity_oidc_scope.user.name
  ]
}
