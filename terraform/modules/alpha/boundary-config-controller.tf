


data "template_file" "boundary_controller" {
  template = <<-EOT
# https://www.linkedin.com/in/markchristopherwest/
disable_mlock = true

# https://developer.hashicorp.com/boundary/docs/configuration/controller#complete-configuration-example
controller {
  name = "boundary"
  description = "A Boundary controller for demo!"
  database {
      url = "env://BOUNDARY_PG_URL"
  }
}

# https://developer.hashicorp.com/boundary/docs/configuration/listener/tcp#tcp-listener-examples
listener "tcp" {
  address = "127.0.0.1:9200"
  purpose = "api"
  tls_disable = true 
}

listener "tcp" {
  address = "127.0.0.1:9201"
  purpose = "cluster"
  tls_disable = true 
}

listener "tcp" {
  address = "127.0.0.1:9202"
	purpose = "proxy"
	tls_disable = true
}

# https://developer.hashicorp.com/boundary/docs/configuration/kms/transit#transit-example
kms "transit" {
  purpose            = "root"
  address            = "http://vault:8200"
  token              = "${vault_approle_auth_backend_login.boundary_kms_root_login.client_token}"
  disable_renewal    = "false"

  // Key configuration
  key_name           = "${vault_transit_secret_backend_key.boundary_root.name}"
  mount_path         = "${vault_transit_secret_backend_key.boundary_root.backend}"
  # namespace          = "ns1/"

  // TLS Configuration
  # tls_ca_cert        = "/etc/vault/ca_cert.pem"
  # tls_client_cert    = "/etc/vault/client_cert.pem"
  # tls_client_key     = "/etc/vault/ca_cert.pem"
  tls_server_name    = "vault"
  tls_skip_verify    = "true"
}

kms "transit" {
  purpose            = "worker-auth"
  address            = "http://vault:8200"
  token              = "${vault_approle_auth_backend_login.boundary_kms_worker_login.client_token}"
  disable_renewal    = "false"

  // Key configuration
  key_name           = "${vault_transit_secret_backend_key.boundary_worker_auth.name}"
  mount_path         = "${vault_transit_secret_backend_key.boundary_worker_auth.backend}"
  # namespace          = "ns1/"

  // TLS Configuration
  # tls_ca_cert        = "/etc/vault/ca_cert.pem"
  # tls_client_cert    = "/etc/vault/client_cert.pem"
  # tls_client_key     = "/etc/vault/ca_cert.pem"
  tls_server_name    = "vault"
  tls_skip_verify    = "true"
}

kms "transit" {
  purpose            = "recovery"
  address            = "http://vault:8200"
  token              = "${vault_approle_auth_backend_login.boundary_kms_recovery_login.client_token}"
  disable_renewal    = "false"

  // Key configuration
  key_name           = "${vault_transit_secret_backend_key.boundary_recovery.name}"
  mount_path         = "${vault_transit_secret_backend_key.boundary_recovery.backend}"
  # namespace          = "ns1/"

  // TLS Configuration
  # tls_ca_cert        = "/etc/vault/ca_cert.pem"
  # tls_client_cert    = "/etc/vault/client_cert.pem"
  # tls_client_key     = "/etc/vault/ca_cert.pem"
  tls_server_name    = "vault"
  tls_skip_verify    = "true"
}

  EOT
  vars = {
    # boundary_kms_recovery_token = "${vault_approle_auth_backend_login.boundary_kms_recovery_login.client_token}"
    # boundary_kms_recovery_key_name = "${vault_transit_secret_backend_key.boundary_recovery.name}"
    # boundary_kms_recovery_mount_path = "${vault_transit_secret_backend_key.boundary_recovery.backend}"
    # boundary_kms_root_token = "${vault_approle_auth_backend_login.boundary_kms_root_login.client_token}"
    # boundary_kms_root_key_name = "${vault_transit_secret_backend_key.boundary_kms_root_login.name}"
    # boundary_kms_root_mount_path = "${vault_transit_secret_backend_key.boundary_kms_root_login.backend}"
    # boundary_kms_worker_auth_token = "${vault_approle_auth_backend_login.worker_auth.client_token}"
    # boundary_kms_worker_auth_key_name = "${vault_transit_secret_backend_key.worker_auth.name}"
    # boundary_kms_worker_auth_mount_path = "${vault_transit_secret_backend_key.worker_auth.backend}"
  }
}

output "boundary_root_name" {
  value = vault_transit_secret_backend_key.boundary_root.keys.0["name"]
}


output "boundary_root_public_key" {
  value = vault_transit_secret_backend_key.boundary_root.keys.0["public_key"]
}


resource "local_file" "boundary_controller_config" {
  content  = data.template_file.boundary_controller.rendered
  filename = "${path.module}/../secrets/config-boundary-controller.hcl"
}
