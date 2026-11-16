resource "newrelic_alert_policy" "phase4_business_policy" {
  name                = "[${var.cluster_name}] Phase 4 Microservices & Platform Health"
  incident_preference = "PER_CONDITION"
}

# 1. Alertas para falhas no processamento de APIs de negócio (HTTP 5xx > 1%)
resource "newrelic_nrql_alert_condition" "business_api_failures" {
  account_id                   = var.newrelic_account_id
  policy_id                    = newrelic_alert_policy.phase4_business_policy.id
  name                         = "Falha no Processamento de APIs de Negocio (> 1% erros 5xx)"
  type                         = "static"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT percentage(count(*), WHERE status LIKE '5%') FROM Metric WHERE metricName = 'http.server.requests' AND (uri LIKE '%/work-orders%' OR uri LIKE '%/payments%' OR uri LIKE '%/executions%')"
  }

  critical {
    operator              = "above"
    threshold             = 1.0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

# 2. Alertas para falhas nas integrações críticas (PostgreSQL, MongoDB e Kafka via Log de Erro)
resource "newrelic_nrql_alert_condition" "integration_failures" {
  account_id                   = var.newrelic_account_id
  policy_id                    = newrelic_alert_policy.phase4_business_policy.id
  name                         = "Erros e Falhas nas Integracoes (PostgreSQL / MongoDB / Kafka)"
  type                         = "static"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT count(*) FROM Log WHERE (message LIKE '%SQLException%' OR message LIKE '%MongoException%' OR message LIKE '%KafkaException%' OR level = 'ERROR') AND namespace_name = '${var.workload_namespace}'"
  }

  critical {
    operator              = "above"
    threshold             = 5
    threshold_duration    = 300
    threshold_occurrences = "AT_LEAST_ONCE"
  }
}

# 3. Alertas para Healthcheck e Uptime (Pods de microsserviços não saudáveis)
resource "newrelic_nrql_alert_condition" "pod_healthcheck_failed" {
  account_id                   = var.newrelic_account_id
  policy_id                    = newrelic_alert_policy.phase4_business_policy.id
  name                         = "Healthcheck Failed - Pods Not Ready (isReady = 0)"
  type                         = "static"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT count(*) FROM K8sPodSample WHERE namespaceName = '${var.workload_namespace}' AND isReady = 0"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

# 4. Alertas para Latência das APIs (p95 acima de 2.000ms / 2s)
resource "newrelic_nrql_alert_condition" "api_latency_high" {
  account_id                   = var.newrelic_account_id
  policy_id                    = newrelic_alert_policy.phase4_business_policy.id
  name                         = "Alta Latencia nas APIs (p95 > 2s)"
  type                         = "static"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT percentile(http.server.requests * 1000, 95) FROM Metric WHERE metricName = 'http.server.requests' AND uri NOT LIKE '%actuator%'"
  }

  critical {
    operator              = "above"
    threshold             = 2000
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

# 5. Alertas para Consumo de Recursos do Kubernetes (Memória do Pod > 90% do Limit)
resource "newrelic_nrql_alert_condition" "pod_memory_pressure" {
  account_id                   = var.newrelic_account_id
  policy_id                    = newrelic_alert_policy.phase4_business_policy.id
  name                         = "Consumo Excessivo de Memoria no Pod (> 90%)"
  type                         = "static"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT average(memoryWorkingSetBytes / memoryLimitBytes * 100) FROM K8sContainerSample WHERE namespaceName = '${var.workload_namespace}'"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

# 6. Alerta para Indisponibilidade do Kong API Gateway
resource "newrelic_nrql_alert_condition" "kong_gateway_unhealthy" {
  account_id                   = var.newrelic_account_id
  policy_id                    = newrelic_alert_policy.phase4_business_policy.id
  name                         = "Kong API Gateway Down / Not Ready"
  type                         = "static"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT count(*) FROM K8sPodSample WHERE podName LIKE '%kong%' AND isReady = 0"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 120
    threshold_occurrences = "ALL"
  }
}

# 7. Alerta para Esgotamento do Pool de Conexões do PostgreSQL (HikariCP Timeout)
resource "newrelic_nrql_alert_condition" "postgres_pool_exhausted" {
  account_id                   = var.newrelic_account_id
  policy_id                    = newrelic_alert_policy.phase4_business_policy.id
  name                         = "PostgreSQL Connection Pool Saturated (HikariCP Timeout)"
  type                         = "static"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT latest(hikaricp.connections.timeout) FROM Metric WHERE metricName = 'hikaricp.connections.timeout'"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 180
    threshold_occurrences = "AT_LEAST_ONCE"
  }
}

# 8. Alerta para Indisponibilidade do Apache Kafka (Strimzi Cluster)
resource "newrelic_nrql_alert_condition" "kafka_cluster_unhealthy" {
  account_id                   = var.newrelic_account_id
  policy_id                    = newrelic_alert_policy.phase4_business_policy.id
  name                         = "Apache Kafka Cluster Down / Not Ready"
  type                         = "static"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT count(*) FROM K8sPodSample WHERE (namespaceName = 'infra-kafka' OR podName LIKE '%kafka%') AND isReady = 0"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 180
    threshold_occurrences = "ALL"
  }
}
