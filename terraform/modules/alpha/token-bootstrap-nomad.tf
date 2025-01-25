


resource "random_string" "token_nomad_bootstrap" {
  length           = 32
  special          = true
  override_special = "/@£$"
}

resource "local_file" "token_nomad_bootstrap" {
  content  = random_string.token_nomad_bootstrap.result
  filename = "${path.module}/../secrets/bootstrap-token-nomad.txt"
}
