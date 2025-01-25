resource "vault_database_secret_backend_connection" "cassandra" {
  backend       = vault_mount.cassandra.path
  name          = "cassandra"
  allowed_roles = [
    vault_approle_auth_backend_role.cassandra.role_name,
    # vault_approle_auth_backend_role.dbmysql.role_name,
    # vault_approle_auth_backend_role.dbpostgres.role_name,
    # vault_approle_auth_backend_role.dbredis.role_name
    ]

  cassandra {
    username = "admin"
    password = "changeme"
    hosts    = ["cassandra1.local", "cassandra", "host.docker.internal"]
    port     = 9042
    protocol_version = "3"
  }
}

resource "vault_database_secret_backend_role" "cassandra" {
  backend             = vault_mount.cassandra.path
  name                = "cassandra"
  db_name             = vault_database_secret_backend_connection.cassandra.name
  creation_statements = [
    "CREATE USER '{{username}}' WITH PASSWORD '{{password}}' NOSUPERUSER;", 
    "GRANT SELECT ON ALL KEYSPACES TO {{username}};"]
}