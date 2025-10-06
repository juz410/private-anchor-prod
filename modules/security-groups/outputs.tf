# External ALB
output "external_alb_sg_id" {
  value = module.external_alb_sg.security_group_id
}

# Prometheus / Grafana / Loki
output "prometheus_grafana_loki_server_sg_id" {
  value = module.prometheus_grafana_loki_server_sg.security_group_id
}

# USSD
output "ussd_server_sg_id" {
  value = module.ussd_server_sg.security_group_id
}

# MCN IVR
output "mcn_ivr_server_sg_id" {
  value = module.mcn_ivr_server_sg.security_group_id
}

# ECS Fargate
output "ecs_fargate_server_sg_id" {
  value = module.ecs_fargate_server_sg.security_group_id
}

# Kalsym MySQL DB
output "kalsym_mysql_db_server_sg_id" {
  value = module.kalsym_mysql_db_server_sg.security_group_id
}

# Internal ALB
output "internal_alb_sg_id" {
  value = module.internal_alb_sg.security_group_id
}

# IoT Web Frontend
output "iot_web_frontend_server_sg_id" {
  value = module.iot_web_frontend_server_sg.security_group_id
}

# IoT Web Backend
output "iot_web_backend_server_sg_id" {
  value = module.iot_web_backend_server_sg.security_group_id
}

# DRA
output "dra_server_sg_id" {
  value = module.dra_server_sg.security_group_id
}

# SMSC
output "smsc_server_sg_id" {
  value = module.smsc_server_sg.security_group_id
}

# SCP
output "scp_server_sg_id" {
  value = module.scp_server_sg.security_group_id
}

# OCS
output "ocs_server_sg_id" {
  value = module.ocs_server_sg.security_group_id
}

# Multibyte PostgreSQL DB
output "multibyte_postgresql_db_server_sg_id" {
  value = module.multibyte_postgresql_db_server_sg.security_group_id
}

output "interface_endpoint_sg_id" {
  value = module.interface_endpoint_sg.security_group_id
}
