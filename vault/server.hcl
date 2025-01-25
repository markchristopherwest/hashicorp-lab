# Full configuration options can be found at https://www.vaultproject.io/docs/configuration

ui = true


storage "raft" {
  path = "/tmp"
  node_id = "docker"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = true
  unauthenticated_metrics_access = true
  unauthenticated_pprof_access = true
  unauthenticated_in_flight_requests_access = true
}

listener "tcp" {
  address = "127.0.0.1:8201"
  tls_disable = true
}

telemetry {
  usage_gauge_period = "10m"
  maximum_gauge_cardinality = 500
  disable_hostname = false
  enable_hostname_label = false
  lease_metrics_epsilon = "1h"
  num_lease_metrics_buckets = 168
  add_lease_metrics_namespace_labels = false
  filter_default = true

  statsite_address = "grafana"
}


api_addr = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"

// license_path = "/opt/vault/lic/vault.hclic"
