# https://learn.hashicorp.com/tutorials/nomad/multiregion-deployments?in=nomad/enterprise
data_dir  = "/var/lib/nomad"
bind_addr  = "0.0.0.0"
datacenter = "$USER"
name       = "$HOSTNAME"
region     = "docker"
# https://www.nomadproject.io/docs/configuration
advertise {
  http = "127.0.0.1"
  rpc  = "127.0.0.1"
  serf = "127.0.0.1"
}
# https://www.nomadproject.io/docs/configuration/server
server {
  default_scheduler_config {
    scheduler_algorithm             = "spread"
    memory_oversubscription_enabled = true
    reject_job_registration         = false
    pause_eval_broker               = false

    preemption_config {
      batch_scheduler_enabled    = true
      system_scheduler_enabled   = true
      service_scheduler_enabled  = true
      sysbatch_scheduler_enabled = true
    }
  }
}

telemetry {
 collection_interval = "5s",
 publish_allocation_metrics = true,
 publish_node_metrics = true,
 prometheus_metrics = true
}


client {
  enabled       = true
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}


consul {
  address = "1.2.3.4:8500"
}

# https://developer.hashicorp.com/nomad/tutorials/integrate-vault/vault-postgres#configure-nomad
vault {
  enabled = true
  address = "http://vault:8200"
  task_token_ttl = "1h"
  create_from_role = "nomad-cluster"
  token = "$VAULT_TOKEN"
}


# https://www.nomadproject.io/docs/configuration/tls
#tls {
#  http = true
#  rpc  = true
#  ca_file   = "/opt/nomad/tls/bundle-$domain.crt"
#  cert_file = "/opt/${product_name}/tls/server-$product_name.$domain.crt"
#  key_file  = "/opt/${product_name}/tls/server-$product_name.$domain.key"
#}
# https://learn.hashicorp.com/tutorials/nomad/access-control-tokens?in=nomad/access-control
acl {
  enabled = true
}