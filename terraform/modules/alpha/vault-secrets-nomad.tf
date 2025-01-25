resource "vault_nomad_secret_backend" "config" {
  backend                   = "nomad"
  description               = "test description"
  default_lease_ttl_seconds = "3600"
  max_lease_ttl_seconds     = "7200"
  address                   = "http://127.0.0.1:4646"
  token                     = "ae20ceaa-..."
}

resource "vault_nomad_secret_role" "test" {
  backend  = vault_nomad_secret_backend.config.backend
  role     = "test"
  type     = "client"
  policies = ["readonly"]
}