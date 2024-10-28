
# https://www.consul.io/docs/agent#server-node-with-encryption-enabled
bind_addr = "0.0.0.0"
bootstrap_expect = 1
# https://www.consul.io/docs/agent/options#bootstrap_expect
datacenter = "docker"
data_dir = "/opt/consul/data"
log_level = "debug"
node_name = "consul-0"
server = true
addresses = {
  http = "127.0.0.1"
}
# $stanza_retry_join
# https://learn.hashicorp.com/tutorials/consul/deployment-guide#datacenter-auto-join
ports {
  http = 8500
}
# https://www.consul.io/docs/security/encryption
#auto_encrypt {
#  allow_tls = true
#}
# encrypt = "$consul_keygen"
# https://www.consul.io/commands/tls/cert
# https://learn.hashicorp.com/tutorials/consul/tls-encryption-secure
# $stanza_tls
# https://developer.hashicorp.com/consul/docs/upgrading/upgrade-specific#upgrading-specific-versions
# https://license.hashicorp.services/
# $license_path
# https://www.consul.io/docs/agent/telemetry
# telemetry {
#   disable_compat_1.9 = true
# }
# https://www.consul.io/docs/connect/observability/ui-visualization
ui_config {
  enabled = true
}
# https://www.consul.io/docs/agent
# Make UI access happen
client_addr = "0.0.0.0"