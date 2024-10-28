

resource "random_pet" "domain" {
  length = 2
#   count  = length(var.users) / 2
  separator = "."
}

resource "vault_mount" "foo_root" {
  path                      = "pki-foo-root"
  type                      = "pki"
  description               = "PKI Secrets Engine for Foo's root CA"
  default_lease_ttl_seconds = 8640000
  max_lease_ttl_seconds     = 8640000
}

resource "vault_mount" "foo_intermediate" {
  path                      = "pki-foo-int"
  type                      = "pki"
  description               = "PKI Secrets Engine for Foo's intermediate CA"
  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 86400
}

resource "vault_pki_secret_backend_root_cert" "foo" {
  backend              = vault_mount.foo_root.path
  type                 = "internal"
  common_name          = "${random_pet.domain.id} Root CA"
  ttl                  = 86400
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = "Organizational Unit"
  organization         = "${random_pet.domain.id}Org"
  country              = "US"
  locality             = "San Francisco"
  province             = "CA"
}

resource "vault_pki_secret_backend_intermediate_cert_request" "foo" {
  backend     = vault_mount.foo_intermediate.path
  type        = vault_pki_secret_backend_root_cert.foo.type
  common_name = "${random_pet.domain.id} SubOrg Intermediate CA"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "foo" {
  backend              = vault_mount.foo_root.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.foo.csr
  common_name          = vault_pki_secret_backend_intermediate_cert_request.foo.common_name
  exclude_cn_from_sans = true
  ou                   = "SubUnit"
  organization         = "SubOrg"
  country              = "US"
  locality             = "San Francisco"
  province             = "CA"
  revoke               = true
  max_path_length      = 1
}

resource "vault_pki_secret_backend_intermediate_set_signed" "foo" {
  backend     = vault_mount.foo_intermediate.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.foo.certificate
}

resource "vault_pki_secret_backend_role" "foo_root" {
  backend     = vault_mount.foo_root.path
  name             = "my_admin"
  ttl              = 3600
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["${random_pet.domain.id}.com", "${random_pet.domain.id}.domain"]
  allow_subdomains = true
}

resource "vault_pki_secret_backend_role" "foo_int" {
  backend     = vault_mount.foo_intermediate.path
  name             = "my_admin"
  ttl              = 3600
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  # allowed_domains  = ["${random_pet.domain.id}.com", "${random_pet.domain.id}.domain"]
  allow_subdomains = true
}

resource "vault_pki_secret_backend_cert" "app" {
  depends_on = [vault_pki_secret_backend_role.foo_root]

  backend = vault_mount.foo_root.path
  name = vault_pki_secret_backend_role.foo_root.name

  common_name = "app.${random_pet.domain.id}.domain"
}

resource "local_file" "foo" {
  content = format("%s\n%s", vault_pki_secret_backend_cert.app.private_key,vault_pki_secret_backend_cert.app.ca_chain)
  filename = format("%s/%s", "${path.module}/../secrets", format("%s_bundle.pem", replace("${vault_pki_secret_backend_cert.app.common_name}", ".", "_")))
}

resource "local_file" "foo_ca_chain" {
  content = vault_pki_secret_backend_cert.app.ca_chain
  filename = format("%s/%s", "${path.module}/../secrets", format("%s_ca.pem", replace("${vault_pki_secret_backend_cert.app.common_name}", ".", "_")))
}

resource "local_file" "foo_certificate" {
  content = vault_pki_secret_backend_cert.app.certificate
  filename = format("%s/%s", "${path.module}/../secrets", format("%s_crt.pem", replace("${vault_pki_secret_backend_cert.app.common_name}", ".", "_")))
}

resource "local_file" "foo_key" {
  content = vault_pki_secret_backend_cert.app.private_key
  filename = format("%s/%s", "${path.module}/../secrets", format("%s_key.pem", replace("${vault_pki_secret_backend_cert.app.common_name}", ".", "_")))
}

