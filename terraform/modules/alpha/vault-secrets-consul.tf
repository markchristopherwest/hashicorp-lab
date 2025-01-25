resource "vault_consul_secret_backend" "lab" {
  path        = "consul"
  description = "Manages the Consul backend"

  address = "127.0.0.1:8500"
  token   = "4240861b-ce3d-8530-115a-521ff070dd29"
}

resource "vault_consul_secret_backend_role" "example" {
  name    = "lab-role"
  backend = vault_consul_secret_backend.lab.path

  consul_policies = [
    "example-policy",
  ]
}