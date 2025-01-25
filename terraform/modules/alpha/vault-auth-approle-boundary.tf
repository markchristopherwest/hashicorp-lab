resource "vault_approle_auth_backend_role" "boundary_kms_recovery" {
  backend        = vault_auth_backend.approle.path
  role_name      = "boundary_kms_recovery"
  token_policies = [vault_policy.boundary_transit.name]
}

resource "vault_approle_auth_backend_role" "boundary_kms_root" {
  backend        = vault_auth_backend.approle.path
  role_name      = "boundary_kms_root"
  token_policies = [vault_policy.boundary_transit.name]
}

resource "vault_approle_auth_backend_role" "boundary_kms_worker" {
  backend        = vault_auth_backend.approle.path
  role_name      = "boundary_kms_worker"
  token_policies = [vault_policy.boundary_transit.name]
}

resource "vault_approle_auth_backend_role_secret_id" "boundary_kms_recovery_id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.boundary_kms_recovery.role_name
}

resource "vault_approle_auth_backend_role_secret_id" "boundary_kms_root_id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.boundary_kms_root.role_name
}


resource "vault_approle_auth_backend_role_secret_id" "boundary_kms_worker_id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.boundary_kms_worker.role_name
}

resource "vault_approle_auth_backend_login" "boundary_kms_recovery_login" {
  backend   = vault_auth_backend.approle.path
  role_id   = vault_approle_auth_backend_role.boundary_kms_recovery.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.boundary_kms_recovery_id.secret_id
}

resource "vault_approle_auth_backend_login" "boundary_kms_root_login" {
  backend   = vault_auth_backend.approle.path
  role_id   = vault_approle_auth_backend_role.boundary_kms_root.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.boundary_kms_root_id.secret_id
}

resource "vault_approle_auth_backend_login" "boundary_kms_worker_login" {
  backend   = vault_auth_backend.approle.path
  role_id   = vault_approle_auth_backend_role.boundary_kms_worker.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.boundary_kms_worker_id.secret_id
}
