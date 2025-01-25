resource "vault_database_secret_backend_connection" "mysql" {
  backend       = vault_mount.mysql.path
  name          = "mysql"
  allowed_roles = [
    # vault_approle_auth_backend_role.dbcassandra.role_name,
    vault_approle_auth_backend_role.mysql.role_name,
    # vault_approle_auth_backend_role.dbmysql.role_name,
    # vault_approle_auth_backend_role.dbpostgres.role_name,
    # vault_approle_auth_backend_role.dbredis.role_name
    ]

  mysql {
    username     = "root"
    password     = "changeme"
    # endpoint     = "mysql:3306"
    # database     = "mysql"
    # tls_ca       = file("${path.module}/certs/ca.pem")
    # tls_cert     = file("${path.module}/certs/client-cert.pem")
    # tls_key      = file("${path.module}/certs/client-key.pem")
    
    connection_url = "{{username}}:{{password}}@tcp(mysql:3306)/"
  }
}

resource "vault_database_secret_backend_role" "mysql" {
  backend             = vault_mount.mysql.path
  name                = "mysql"
  db_name             = vault_database_secret_backend_connection.mysql.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';"]
}