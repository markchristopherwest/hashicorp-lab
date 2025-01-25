

resource "vault_approle_auth_backend_role" "nomad_client" {
  backend        = vault_auth_backend.approle.path
  role_name      = "nomad_client"
  token_policies = [vault_policy.boundary_transit.name]
}

resource "vault_approle_auth_backend_role" "nomad_server" {
  backend        = vault_auth_backend.approle.path
  role_name      = "nomad_server"
  token_policies = [vault_policy.boundary_transit.name]
}
