
data "vault_policy_document" "ldap" {
  rule {
    path         = "ldap_*/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Work with LDAP secrets engine"
  }
  rule {
    path         = "sys/mounts/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Enable secrets engine"
  }
  rule {
    path         = "sys/mounts"
    capabilities = [ "read", "list"]
    description  = "List enabled secrets engine"
  }
}

resource "vault_policy" "ldap" {
  name   = "ldap_policy"
  policy = data.vault_policy_document.ldap.hcl
}

resource "vault_ldap_secret_backend" "config" {
  for_each = {
    for k, v in var.ldap_manifest : k => v
  }
  path          = "ldap-${each.key}-secrets"
  description = "LDAP Secrets Engine for ${title(each.key)}"
  binddn        = "${each.value.binddn}"
  bindpass      = "${each.value.bindpass}"
  url           = "${each.value.url}"
  userdn        = "${each.value.userdn}"
}

resource "vault_ldap_secret_backend_dynamic_role" "role" {
  for_each = {
    for k, v in var.ldap_manifest : k => v
  }
  mount         = vault_ldap_secret_backend.config[each.key].path
  role_name     = "ldap-dynamic-secrets-${each.key}"
  creation_ldif = each.value.creation_ldif
  deletion_ldif = each.value.deletion_ldif
  rollback_ldif = each.value.rollback_ldif
  default_ttl   = each.value.default_ttl
  max_ttl       = each.value.max_ttl
}
