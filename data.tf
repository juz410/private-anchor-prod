data "aws_ami" "amazon_linux" {
  owners = ["self"] # your account

  filter {
    name   = "image-id"
    values = ["ami-00968c4a471ceb592"]
  }
}

data "aws_rds_engine_version" "postgres_latest" {
  engine = "postgres"
}

data "aws_rds_engine_version" "mysql_latest" {
  engine = "mysql"
}


data "aws_kms_key" "rds_cmk" {
  key_id = "alias/anchor-prod-rds-kms-001"
}

data "aws_kms_key" "secret_manager_cmk" {
  key_id = "alias/anchor-prod-secret-manager-kms-001"
}

data "aws_kms_key" "cloudwatch_logs_cmk" {
  key_id = "alias/anchor-prod-cloudwatch-logs-kms-001"
}