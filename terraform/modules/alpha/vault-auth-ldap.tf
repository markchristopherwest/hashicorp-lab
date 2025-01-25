

resource "vault_mount" "ldap" {
  path        = "ldap-foo-auth"
  type        = "ldap"
  description = "LDAP Auth Engine for Foo"

  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
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



resource "vault_ldap_auth_backend_user" "admin" {
  username = "admin"
  policies = ["admin", "default"]
  backend  = vault_ldap_auth_backend.ldap.path
}
