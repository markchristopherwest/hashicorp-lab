resource "vault_database_secret_backend_connection" "redis" {
  backend       = vault_mount.redis.path
  name          = "redis"
  allowed_roles = [
    # vault_approle_auth_backend_role.dbcassandra.role_name,
    vault_approle_auth_backend_role.redis.role_name,
    # vault_approle_auth_backend_role.dbmysql.role_name,
    # vault_approle_auth_backend_role.dbpostgres.role_name,
    # vault_approle_auth_backend_role.dbredis.role_name
    ]

  redis {
    host = "redis"
    username = "default"
    password = "changeme"
  }
}

resource "vault_database_secret_backend_role" "redis" {
  backend             = vault_mount.redis.path
  name                = "redis"
  db_name             = vault_database_secret_backend_connection.redis.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';"]
}