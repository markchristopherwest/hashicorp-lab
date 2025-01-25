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






# output "vault_token_for_identity_entity" {
#   value     = vault_token.boundary.client_token
#   sensitive = true
# }

