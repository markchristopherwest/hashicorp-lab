
resource "vault_mount" "cassandra" {
  path = "cassandra"
  type = "database"

  description = "Database Secrets Engine for cassandra"
}

resource "vault_mount" "mssql" {
  path = "mssql"
  type = "database"

  description = "Database Secrets Engine for mssql"
}

resource "vault_mount" "mysql" {
  path = "mysql"
  type = "database"

  description = "Database Secrets Engine for mysql"
}

resource "vault_mount" "oracle" {
  path = "oracle"
  type = "database"

  description = "Database Secrets Engine for oracle"
}

resource "vault_mount" "postgres" {
  path = "postgres"
  type = "database"

  description = "Database Secrets Engine for postgres"
}


resource "vault_mount" "redis" {
  path = "redis"
  type = "database"

  description = "Database Secrets Engine for redis"
}
