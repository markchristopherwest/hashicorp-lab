resource "vault_approle_auth_backend_role" "consul_client" {
  backend        = vault_auth_backend.approle.path
  role_name      = "consul_client"
  token_policies = [vault_policy.boundary_transit.name]
}

resource "vault_approle_auth_backend_role" "consul_server" {
  backend        = vault_auth_backend.approle.path
  role_name      = "consul_server"
  token_policies = [vault_policy.boundary_transit.name]
}
