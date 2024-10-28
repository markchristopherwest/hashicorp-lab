

resource "vault_mount" "ldap" {
  path        = "ldap-foo-auth"
  type        = "ldap"
  description = "LDAP Auth Engine for Foo"

  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}