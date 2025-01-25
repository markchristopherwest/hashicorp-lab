# resource "vault_database_secret_backend_connection" "oracle" {
#   backend       = vault_mount.oracle.path
#   name          = "oracle"
#   allowed_roles = [
#     vault_approle_auth_backend_role.oracle.role_name
#     ]

#   oracle {
#     username     = "system"
#     password     = "changeme"
    
#     connection_url = "{{username}}/{{password}}@oracle:1521/OraDoc.localhost"
#   }
# }

# resource "vault_database_secret_backend_role" "oracle" {
#   backend             = vault_mount.oracle.path
#   name                = "oracle"
#   db_name             = vault_database_secret_backend_connection.oracle.name
#   creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';"]
# }