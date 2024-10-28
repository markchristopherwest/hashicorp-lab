# https://learn.hashicorp.com/tutorials/nomad/multiregion-deployments?in=nomad/enterprise
data_dir  = "/var/lib/nomad"
bind_addr  = "0.0.0.0"
datacenter = "$name_datacenter"
name       = "nomad"
region     = "docker"
# https://www.nomadproject.io/docs/configuration
advertise {
  http = "127.0.0.1"
  rpc  = "127.0.0.1"
  serf = "127.0.0.1"
}
# https://www.nomadproject.io/docs/configuration/server
server {
  # $license_path
  enabled = true
  bootstrap_expect = 1
  # https://www.nomadproject.io/docs/configuration/server_join
  # $stanza_server_join
  # https://www.nomadproject.io/docs/configuration/server#configuring-scheduler-config
  default_scheduler_config {
    scheduler_algorithm = "spread"
    memory_oversubscription_enabled = true
    preemption_config {
      batch_scheduler_enabled    = true
      system_scheduler_enabled   = true
      service_scheduler_enabled  = true
      sysbatch_scheduler_enabled = true
    }
  }
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