


data "template_file" "boundary_worker_ingress" {
  template = <<-EOT


disable_mlock = true

worker {
  name = "boundary-worker"
  # description = "A worker for a docker demo"
  // public address 127 because we're portforwarding the connection from docker to host machine.
  // So for the client running in host machine, the connection ip is 127
  // If you're using this in a remote server, then the ip should be changed to machine public address, so that your local machine can communicate to this worker.
  public_addr = "127.0.0.1"



  # auth_storage_path = "/boundary/auth"
  # controller_generated_activation_token = "env://BOUNDARY_CGAT"
  # controller_generated_activation_token = "XO"
  public_addr = "boundary-worker"
  # recording_storage_path = "/minio/boundary"

  tags {
    type = ["boundary-worker"]
  }

  initial_upstreams = ["boundary:9200"]
}

listener "tcp" {
  address = "boundary-worker:9210"
  purpose = "api"
  tls_disable = true 
}

# listener "tcp" {
#   address = "boundary-controller:9200"
#   purpose = "cluster"
#   tls_disable = true 
# }

listener "tcp" {
  address = "boundary-worker:9212"
  purpose = "proxy"
  tls_disable = true
}

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
  # vars = {
  #   boundary_kms_global_root = map(vault_transit_secret_backend_key.boundary_root.keys[0])
  #   boundary_kms_global_worker_auth = map(vault_transit_secret_backend_key.boundary_worker_auth.keys[0])
  #   boundary_kms_global_recovery = map(vault_transit_secret_backend_key.boundary_recovery.keys[0])
  # }
}


resource "local_file" "boundary_worker_ingress" {
  content  = data.template_file.boundary_worker_ingress.rendered
  filename = "${path.module}/../secrets/config-boundary-worker-ingress.hcl"
}
