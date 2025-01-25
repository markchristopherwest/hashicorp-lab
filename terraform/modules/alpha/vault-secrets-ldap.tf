

resource "vault_ldap_secret_backend" "openldap" {
  path     = "foo"
  binddn   = "CN=admin,DC=foo,DC=local"
  bindpass = "admin"
  url      = "ldap://openldap"
  userdn   = "DC=foo,DC=local"
}

resource "vault_ldap_secret_backend_dynamic_role" "openldap" {
  mount         = vault_ldap_secret_backend.openldap.path
  role_name     = "ldap-dynamic-secrets-foo"
  creation_ldif = <<EOT
dn: uid={{.Username}},dc=foo,dc=local
uid: {{.Username}}
cn: {{.Username}}
sn: 3
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
loginShell: /bin/bash
homeDirectory: /home/{{.Username}}
uidNumber: 14583102
gidNumber: 14564100
userPassword: {{.Password}}
mail: {{.Username}}@foo.local
gecos: {{.Username}}
EOT
  deletion_ldif = <<EOT
dn: uid={{.Username}},dc=foo,dc=local
changetype: delete
EOT
  rollback_ldif = <<EOT
dn: uid={{.Username}},dc=foo,dc=local
changetype: delete
EOT
  default_ttl   = 3600
  max_ttl       = 86400
}
