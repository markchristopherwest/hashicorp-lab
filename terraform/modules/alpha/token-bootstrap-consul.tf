


resource "random_string" "token_consul_bootstrap" {
  length           = 32
  special          = true
  override_special = "/@£$"
}

resource "local_file" "token_consul_bootstrap" {
  content  = random_string.token_consul_bootstrap.result
  filename = "${path.module}/../secrets/bootstrap-token-consul.txt"
}
