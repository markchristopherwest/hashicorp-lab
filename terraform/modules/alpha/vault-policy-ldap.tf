
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
    capabilities = ["read", "list"]
    description  = "List enabled secrets engine"
  }
}
resource "vault_policy" "ldap" {
  name   = "ldap"
  policy = data.vault_policy_document.ldap.hcl
}