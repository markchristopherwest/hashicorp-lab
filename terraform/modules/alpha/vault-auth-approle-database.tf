resource "vault_approle_auth_backend_role" "cassandra" {
  backend        = vault_auth_backend.approle.path
  role_name      = "cassandra"
  token_policies = [vault_policy.database.name]
}

resource "vault_approle_auth_backend_role_secret_id" "cassandra" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.cassandra.role_name
}

resource "vault_approle_auth_backend_login" "cassandra" {
  backend   = vault_auth_backend.approle.path
  role_id   = vault_approle_auth_backend_role.cassandra.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.cassandra.secret_id
}

resource "vault_approle_auth_backend_role" "mssql" {
  backend        = vault_auth_backend.approle.path
  role_name      = "mssql"
  token_policies = [vault_policy.database.name]
}

resource "vault_approle_auth_backend_role_secret_id" "mssql" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.mssql.role_name
}

resource "vault_approle_auth_backend_login" "mssql" {
  backend   = vault_auth_backend.approle.path
  role_id   = vault_approle_auth_backend_role.mssql.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.mssql.secret_id
}

resource "vault_approle_auth_backend_role" "mysql" {
  backend        = vault_auth_backend.approle.path
  role_name      = "mysql"
  token_policies = [vault_policy.database.name]
}

resource "vault_approle_auth_backend_role_secret_id" "mysql" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.mysql.role_name
}

resource "vault_approle_auth_backend_login" "mysql" {
  backend   = vault_auth_backend.approle.path
  role_id   = vault_approle_auth_backend_role.mysql.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.mysql.secret_id
}

resource "vault_approle_auth_backend_role" "postgres" {
  backend        = vault_auth_backend.approle.path
  role_name      = "postgres"
  token_policies = [vault_policy.database.name]
}

resource "vault_approle_auth_backend_role_secret_id" "postgres" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.postgres.role_name
}

resource "vault_approle_auth_backend_login" "postgres" {
  backend   = vault_auth_backend.approle.path
  role_id   = vault_approle_auth_backend_role.postgres.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.postgres.secret_id
}

resource "vault_approle_auth_backend_role" "redis" {
  backend        = vault_auth_backend.approle.path
  role_name      = "redis"
  token_policies = [vault_policy.database.name]
}

resource "vault_approle_auth_backend_role_secret_id" "redis" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.redis.role_name
}

resource "vault_approle_auth_backend_login" "redis" {
  backend   = vault_auth_backend.approle.path
  role_id   = vault_approle_auth_backend_role.redis.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.redis.secret_id
}

resource "vault_approle_auth_backend_role" "oracle" {
  backend        = vault_auth_backend.approle.path
  role_name      = "oracle"
  token_policies = [vault_policy.database.name]
}

resource "vault_approle_auth_backend_role_secret_id" "oracle" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.oracle.role_name
}

resource "vault_approle_auth_backend_login" "oracle" {
  backend   = vault_auth_backend.approle.path
  role_id   = vault_approle_auth_backend_role.oracle.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.oracle.secret_id
}