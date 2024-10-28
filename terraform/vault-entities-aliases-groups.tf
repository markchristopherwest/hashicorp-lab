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

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group#example-usage
resource "vault_identity_group" "internal" {
  name              = "engineering"
  type              = "internal"
  policies          = ["dev", "boundary"]
  member_entity_ids = [vault_identity_entity.boundary.id]

  metadata = {
    version = "2"

  }
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_entity#example-usage
resource "vault_identity_entity" "boundary" {
  name     = "end-user"
  policies = [vault_policy.boundary_default.name]
  metadata = {
    email        = "mark.west@hashicorp.com"
    phone_number = "123-456-7890"
  }
  disabled = false
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_entity_alias#example-usage
resource "vault_identity_entity_alias" "boundary" {
  name           = vault_identity_entity.boundary.name
  mount_accessor = vault_mount.transit.accessor
  canonical_id   = vault_identity_entity.boundary.id
}

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

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy#example-usage
resource "vault_policy" "basic" {
  name = "basic"

  policy = <<EOT
path "auth/token/lookup-accessor" {
  capabilities = ["update"]
}

path "auth/token/revoke-accessor" {
  capabilities = ["update"]
}
EOT
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group#example-usage
resource "vault_identity_group" "boundary" {
  name = "boundary"
  type = "internal"

  external_policies = false

  metadata = {
    version = "2"
  }
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group#example-usage
resource "vault_identity_group_policies" "boundary" {
  policies = [
    "basic",
    "boundary",
    "default"
  ]

  exclusive = true

  group_id = vault_identity_group.boundary.id
}



resource "random_shuffle" "group" {
  input = [
    for k in var.users : k
  ]
  result_count = floor(length(var.users) / 4)
  count        = floor(length(var.users) / 2)
}

resource "random_pet" "group" {
  length = 2
  count  = floor(length(var.users) / 2)
}

resource "vault_identity_group" "inside" {
  for_each = {
    for k, v in random_shuffle.group : k => v.id
  }
  name     = random_pet.group[each.key].id
  type     = "internal"
  policies = [vault_policy.basic.name]

  metadata = {
    version = "2"
  }
}


resource "vault_identity_group" "outside" {
  for_each = toset(["accountants", "executives", "sales", "operations"])
  name     = each.key
  type     = "external"
  policies = [vault_policy.basic.name]

  metadata = {
    version = "2"
  }
}

resource "vault_identity_group_alias" "group-alias" {
  for_each = {
    for k, v in vault_identity_group.outside : k => v.id
  }
  name           = "ldap-${each.key}"
  mount_accessor = vault_mount.ldap.accessor
  canonical_id   = each.value
}

resource "vault_identity_entity" "test" {
  for_each = var.users
  name     = each.key
  policies = vault_identity_group_policies.boundary.policies
  metadata = {
    email        = "${each.key}@example.com"
    phone_number = "123-456-7890"
  }
}

resource "vault_identity_entity_alias" "userpass" {
  for_each = {
    for k, v in vault_identity_entity.test : k => v.id
  }
  name           = "userpass-${each.key}"
  mount_accessor = vault_mount.userpass.accessor
  canonical_id   = each.value
}

resource "vault_ldap_auth_backend" "ldap" {
  path        = vault_mount.ldap.path
  url         = "ldap://openldap"
  userdn      = "DC=foo,DC=local"
  userattr    = "sAMAccountName"
  upndomain   = "BAR.LOCAL"
  discoverdn  = false
  groupdn     = "OU=Groups,DC=foo,DC=local"
  groupfilter = "(&(objectClass=group)(member:1.2.840.113556.1.4.1941:={{.UserDN}}))"
}



resource "vault_identity_entity_alias" "ldap" {
  for_each = {
    for k, v in vault_identity_entity.test : k => v.id
  }
  name           = "ldap-${each.key}"
  mount_accessor = vault_mount.ldap.accessor
  canonical_id   = each.value
}

# resource "vault_identity_group_member_entity_ids" "members" {
#   for_each = {
#     for k, v in vault_identity_group.inside : k => v
#   }
#   exclusive         = true
#   member_entity_ids = [for v in vault_identity_entity.test : v.id]
#   group_id          = vault_identity_group.inside[each.key].id
# }

# resource "vault_identity_group_member_entity_ids" "members" {

#   for_each = {
#     for k, v in random_shuffle.group : k => v.id
#   }
#   exclusive         = true
#   member_entity_ids = [for v in vault_identity_entity.test : v.id]
#   group_id          = vault_identity_group.inside[each.key].id
# }

resource "vault_identity_group_member_entity_ids" "members" {

  for_each = {
    for k, v in random_shuffle.group : k => v.id
  }
  exclusive         = true
  member_entity_ids = [for x in vault_identity_entity.test : x.id if contains(random_shuffle.group[each.key].result, x.name)]

  group_id = vault_identity_group.inside[each.key].id
}


# resource "vault_identity_group_member_group_ids" "members" {
#   for_each = {
#     for k, v in vault_identity_group.inside : k => v
#   }
#   exclusive        = true
#   member_group_ids = [for v in vault_identity_group.inside : v.id]
#   group_id         = each.value.id
# }


# resource "vault_token" "boundary" {
#   role_name = vault_identity_oidc_role.boundary.name

#   policies = ["basic", "boundary"]

#   renewable = true
#   ttl       = "24h"

#   renew_min_lease = 43200
#   renew_increment = 86400

#   metadata = {
#     "purpose" = "service-account"
#   }
# }

output "vault_oidc_endpoint" {
  value     = vault_identity_oidc_provider.boundary.issuer
  sensitive = false
}
output "vault_oidc_client_id" {
  value     = data.vault_identity_oidc_client_creds.boundary.client_id
  sensitive = true
}
output "vault_oidc_client_secret" {
  value     = data.vault_identity_oidc_client_creds.boundary.client_secret
  sensitive = true
}


# output "vault_token_for_identity_entity" {
#   value     = vault_token.boundary.client_token
#   sensitive = true
# }