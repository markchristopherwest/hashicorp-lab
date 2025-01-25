resource "vault_database_secret_backend_connection" "postgres" {
  backend       = vault_mount.postgres.path
  name          = "postgres"
  allowed_roles = [
    # vault_approle_auth_backend_role.dbcassandra.role_name,
    # vault_approle_auth_backend_role.dbmssql.role_name,
    # vault_approle_auth_backend_role.dbmysql.role_name,
    vault_approle_auth_backend_role.postgres.role_name,
    # vault_approle_auth_backend_role.dbredis.role_name
    ]

  postgresql {
    connection_url = "postgres://postgres:postgres@postgres:5432/postgres"
  }
}

resource "vault_database_secret_backend_role" "postgres" {
  backend             = vault_mount.postgres.path
  name                = "postgres"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';"]
}