resource "vault_mount" "db" {
  path = "postgres"
  type = "database"

  description = "Database Secrets Engine for Foo's postgres"
}

resource "vault_database_secret_backend_connection" "postgres" {
  backend       = vault_mount.db.path
  name          = "postgres"
  allowed_roles = ["dev", "prod"]

  postgresql {
    connection_url = "postgres://postgres:postgres@postgres:5432/postgres"
  }
}

resource "vault_database_secret_backend_role" "postgres_dynamic" {
  backend             = vault_mount.db.path
  name                = "dev"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';"]
}