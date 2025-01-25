resource "vault_database_secret_backend_connection" "mssql" {
  backend       = vault_mount.mssql.path
  name          = "mssql"
  allowed_roles = [
    # vault_approle_auth_backend_role.dbcassandra.role_name,
    vault_approle_auth_backend_role.mssql.role_name,
    # vault_approle_auth_backend_role.dbmysql.role_name,
    # vault_approle_auth_backend_role.dbpostgres.role_name,
    # vault_approle_auth_backend_role.dbredis.role_name
    ]

  mssql {
    connection_url = "sqlserver://{{username}}:{{password}}@sql-server:1433"
    username = "sa"
    password = "Contraseña12345678"

  }
}

resource "vault_database_secret_backend_role" "mssql" {
  backend             = vault_mount.mssql.path
  name                = "mssql"
  db_name             = vault_database_secret_backend_connection.mssql.name
  creation_statements = [
    "CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}';",
    "CREATE USER [{{name}}] FOR LOGIN [{{name}}];",
    "GRANT SELECT ON SCHEMA::dbo TO [{{name}}];"
    ]
}