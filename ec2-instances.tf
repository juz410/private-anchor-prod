locals {
  ssm_user_data = <<-EOF
                                #!/bin/bash
                                cd /tmp
                                yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
                                systemctl enable amazon-ssm-agent
                                systemctl start amazon-ssm-agent
                            EOF
}

locals {
  base_userdata = <<-EOF
#!/bin/bash
set -euxo pipefail

# Create journald forwarding directory
mkdir -p /var/log/journal-logs

# Create systemd service to forward journald logs
cat >/etc/systemd/system/journal-to-file.service <<'UNIT'
[Unit]
Description=Export journald to file for CloudWatch Agent
After=network.target

[Service]
ExecStart=/bin/bash -c 'journalctl -f -o short-iso >> /var/log/journal-logs/system.log'
Restart=always

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now journal-to-file.service

# CloudWatch Agent config
mkdir -p /opt/aws/amazon-cloudwatch-agent
cat >/opt/aws/amazon-cloudwatch-agent/config.json <<'JSON'
{
  "agent": { "metrics_collection_interval": 60, "run_as_user": "root" },
  "metrics": {
    "append_dimensions": { "InstanceId": "$${aws:InstanceId}" },
    "metrics_collected": {
      "mem": { "measurement": ["mem_used_percent"], "metrics_collection_interval": 60 },
      "disk": { "measurement": ["used_percent"], "metrics_collection_interval": 60, "resources": ["/"] }
    }
  },
  "logs": {
    "logs_collected": { "files": { "collect_list": [
      { "file_path": "/var/log/journal-logs/system.log",
        "log_group_name": "/ec2/${local.resource_name_prefix}/linux",
        "log_stream_name": "{instance_id}/journal" }
    ]}}
  }
}
JSON



/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/config.json -s

systemctl enable amazon-cloudwatch-agent
systemctl restart amazon-cloudwatch-agent
EOF

  ebs_userdata = <<-EOF
echo "Preparing and mounting extra EBS volume..."
DEV="/dev/nvme1n1"
if [ -b "$DEV" ]; then
  mkfs.xfs -f "$DEV" || mkfs.ext4 -F "$DEV"
  mkdir -p /DATA
  echo "$DEV /DATA xfs defaults,nofail 0 2" >> /etc/fstab || \
  echo "$DEV /DATA ext4 defaults,nofail 0 2" >> /etc/fstab
  mount -a
fi
EOF
}


locals {
  prometheus_grafana_loki_servers = {
    prometheus_grafana_loki_server_01 = {
      name_suffix        = "prometheus-grafana-loki-server-01"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.xlarge"
      subnet_id          = module.vpc.private_kalsym_app_subnet_a_id
      security_group_ids = [module.security_groups.prometheus_grafana_loki_server_sg_id]

      root_volume_size = 100
      root_volume_iops = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 400
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"

    }

    prometheus_grafana_loki_server_02 = {
      name_suffix        = "prometheus-grafana-loki-server-02"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.xlarge"
      subnet_id          = module.vpc.private_kalsym_app_subnet_b_id
      security_group_ids = [module.security_groups.prometheus_grafana_loki_server_sg_id]
      uroot_volume_size  = 100
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 400
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"
    }
  }

  ussd_servers = {
    ussd_server_01 = {
      name_suffix        = "ussd-server-01"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.xlarge"
      subnet_id          = module.vpc.private_kalsym_app_subnet_a_id
      security_group_ids = [module.security_groups.ussd_server_sg_id]
      root_volume_size   = 80
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 80
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"

    }

    ussd_server_02 = {
      name_suffix        = "ussd-server-02"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.xlarge"
      subnet_id          = module.vpc.private_kalsym_app_subnet_b_id
      security_group_ids = [module.security_groups.ussd_server_sg_id]
      root_volume_size   = 80
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 80
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"
    }
  }

  mcn_ivr_servers = {
    mcn_ivr_server_01 = {
      name_suffix        = "mcn-ivr-server-01"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.2xlarge"
      subnet_id          = module.vpc.private_kalsym_app_subnet_a_id
      security_group_ids = [module.security_groups.mcn_ivr_server_sg_id]
      root_volume_size   = 80
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 80
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"

    }

    mcn_ivr_server_02 = {
      name_suffix        = "mcn-ivr-server-02"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.2xlarge"
      subnet_id          = module.vpc.private_kalsym_app_subnet_b_id
      security_group_ids = [module.security_groups.mcn_ivr_server_sg_id]
      root_volume_size   = 80
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 80
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"
    }
  }

  # kalsym_mysql_db_servers = {
  #   kalsym_mysql_db_server_01 = {
  #     name_suffix        = "kalsym-mysql-db-server-01"
  #     ami                = data.aws_ami.amazon_linux.id
  #     instance_type      = "c7i.large"
  #     subnet_id          = module.vpc.private_kalsym_db_subnet_a_id
  #     security_group_ids = [module.security_groups.kalsym_mysql_db_server_sg_id]
  #     root_volume_size   = 100
  #     root_volume_iops   = 3000

  #     ebs_block_devices = [
  #       {
  #         device_name           = "/dev/xvdb"
  #         volume_size           = 200
  #         volume_type           = "gp3"
  #         iops                  = 3000
  #         throughput            = 125
  #         encrypted             = true
  #         delete_on_termination = true
  #       }
  #     ]

  #     backup_8hourly  = false
  #     backup_12hourly = false
  #     backup_daily    = false
  #     backup_weekly   = false
  #     backup_monthly  = false
  #     backup_yearly   = false
  #     user_data       = "${local.base_userdata}\n${local.ebs_userdata}"

  #   }

  #   kalsym_mysql_db_server_02 = {
  #     name_suffix        = "kalsym-mysql-db-server-02"
  #     ami                = data.aws_ami.amazon_linux.id
  #     instance_type      = "c7i.large"
  #     subnet_id          = module.vpc.private_kalsym_db_subnet_b_id
  #     security_group_ids = [module.security_groups.kalsym_mysql_db_server_sg_id]
  #     root_volume_size   = 100
  #     root_volume_iops   = 3000

  #     ebs_block_devices = [
  #       {
  #         device_name           = "/dev/xvdb"
  #         volume_size           = 200
  #         volume_type           = "gp3"
  #         iops                  = 3000
  #         throughput            = 125
  #         encrypted             = true
  #         delete_on_termination = true
  #       }
  #     ]

  #     backup_8hourly  = false
  #     backup_12hourly = false
  #     backup_daily    = false
  #     backup_weekly   = false
  #     backup_monthly  = false
  #     backup_yearly   = false
  #     user_data       = "${local.base_userdata}\n${local.ebs_userdata}"
  #   }
  # }

  iot_web_frontend_servers = {
    iot_web_frontend_server_01 = {
      name_suffix        = "iot-web-frontend-server-01"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.large"
      subnet_id          = module.vpc.private_multibyte_subnet_a_id
      security_group_ids = [module.security_groups.iot_web_frontend_server_sg_id]

      root_volume_size = 80
      root_volume_iops = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 80
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"

    }

    iot_web_frontend_server_02 = {
      name_suffix        = "iot-web-frontend-server-02"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.large"
      subnet_id          = module.vpc.private_multibyte_subnet_a_id
      security_group_ids = [module.security_groups.iot_web_frontend_server_sg_id]
      root_volume_size   = 80
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 80
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"
    }
  }

  iot_web_backend_servers = {
    iot_web_backend_server_01 = {
      name_suffix        = "iot-web-backend-server-01"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "m7i.large"
      subnet_id          = module.vpc.private_multibyte_subnet_a_id
      security_group_ids = [module.security_groups.iot_web_backend_server_sg_id]
      root_volume_size   = 100
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 200
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"

    }

    iot_web_backend_server_02 = {
      name_suffix        = "iot-web-backend-server-02"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "m7i.large"
      subnet_id          = module.vpc.private_multibyte_subnet_a_id
      security_group_ids = [module.security_groups.iot_web_backend_server_sg_id]
      root_volume_size   = 100
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 200
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"
    }
  }

  middleware_api_servers = {
    middleware_api_server_01 = {
      name_suffix        = "middleware-api-server-01"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.large"
      subnet_id          = module.vpc.private_multibyte_subnet_a_id
      security_group_ids = [module.security_groups.middleware_api_server_sg_id]
      root_volume_size   = 80
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 80
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"

    }

    middleware_api_server_02 = {
      name_suffix        = "middleware-api-server-02"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.large"
      subnet_id          = module.vpc.private_multibyte_subnet_a_id
      security_group_ids = [module.security_groups.middleware_api_server_sg_id]
      root_volume_size   = 80
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 80
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"
    }
  }

  dra_servers = {
    dra_server_01 = {
      name_suffix        = "dra-server-01"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.large"
      subnet_id          = module.vpc.private_multibyte_subnet_a_id
      security_group_ids = [module.security_groups.dra_server_sg_id]
      root_volume_size   = 50
      root_volume_iops   = 3000

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}"

    }

    dra_server_02 = {
      name_suffix        = "dra-server-02"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.large"
      subnet_id          = module.vpc.private_multibyte_subnet_a_id
      security_group_ids = [module.security_groups.dra_server_sg_id]
      root_volume_size   = 50
      root_volume_iops   = 3000

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}"
    }
  }

  smsc_servers = {
    smsc_server_01 = {
      name_suffix        = "smsc-server-01"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.xlarge"
      subnet_id          = module.vpc.private_multibyte_subnet_a_id
      security_group_ids = [module.security_groups.smsc_server_sg_id]
      root_volume_size   = 100
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 200
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"

    }

    smsc_server_02 = {
      name_suffix        = "smsc-server-02"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.xlarge"
      subnet_id          = module.vpc.private_multibyte_subnet_a_id
      security_group_ids = [module.security_groups.smsc_server_sg_id]
      root_volume_size   = 100
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 200
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"
    }
  }

  scp_servers = {
    scp_server_01 = {
      name_suffix        = "scp-server-01"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.xlarge"
      subnet_id          = module.vpc.private_multibyte_subnet_a_id
      security_group_ids = [module.security_groups.scp_server_sg_id]
      root_volume_size   = 100
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 200
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"

    }

    scp_server_02 = {
      name_suffix        = "scp-server-02"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.xlarge"
      subnet_id          = module.vpc.private_multibyte_subnet_a_id
      security_group_ids = [module.security_groups.scp_server_sg_id]
      root_volume_size   = 100
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 200
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"
    }
  }

  ocs_servers = {
    ocs_server_01 = {
      name_suffix        = "ocs-server-01"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.xlarge"
      subnet_id          = module.vpc.private_multibyte_subnet_a_id
      security_group_ids = [module.security_groups.ocs_server_sg_id]
      root_volume_size   = 100
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 400
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"

    }

    ocs_server_02 = {
      name_suffix        = "ocs-server-02"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.xlarge"
      subnet_id          = module.vpc.private_multibyte_subnet_a_id
      security_group_ids = [module.security_groups.ocs_server_sg_id]
      root_volume_size   = 100
      root_volume_iops   = 3000

      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 400
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]

      backup_8hourly  = false
      backup_12hourly = false
      backup_daily    = false
      backup_weekly   = false
      backup_monthly  = false
      backup_yearly   = false
      user_data       = "${local.base_userdata}\n${local.ebs_userdata}"
    }
  }






  ec2_servers = merge(
    local.prometheus_grafana_loki_servers,
    local.ussd_servers,
    local.mcn_ivr_servers,
    # local.kalsym_mysql_db_servers,
    local.iot_web_frontend_servers,
    local.iot_web_backend_servers,
    local.middleware_api_servers,
    local.dra_servers,
    local.smsc_servers,
    local.scp_servers,
    local.ocs_servers
  )
}



#FULL EXAMPLE
# locals {
#   ec2_servers = {
#     uat_server = {
#       name_suffix        = "uat-server"
#       ami                = data.aws_ami.amazon_linux.id
#       instance_type      = "c7i.xlarge"
#       subnet_id          = module.vpc.private_subnet_a_id
#       security_group_ids = [module.security_groups.uat_server_sg_id]

#       # Add one extra EBS volume
#       ebs_block_devices = [
#         {
#           device_name           = "/dev/xvdb"  # shows as /dev/nvme1n1 on Nitro instances
#           volume_size           = 100
#           volume_type           = "gp3"
#           iops                  = 3000
#           throughput            = 125
#           encrypted             = true
#           delete_on_termination = true
#           # kms_key_id          = "arn:aws:kms:..."  # optional – omit to use account default
#         }
#       ]
# backup_hourly = false
# backup_daily = false
# backup_weekly = false
# backup_monthly = false

#       user_data = <<-EOF
#         #!/bin/bash
#         set -euxo pipefail
#         # Install SSM
#         cd /tmp
#         yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
#         systemctl enable --now amazon-ssm-agent

#         # --- OPTIONAL: prepare and mount the extra EBS volume ---
#         # On Nitro, /dev/xvdb appears as /dev/nvme1n1
#         DEV="/dev/nvme1n1"
#         if [ -b "$DEV" ]; then
#           mkfs.xfs -f "$DEV" || mkfs.ext4 -F "$DEV"
#           mkdir -p /data
#           echo "$DEV /data xfs defaults,nofail 0 2" >> /etc/fstab || \
#           echo "$DEV /data ext4 defaults,nofail 0 2" >> /etc/fstab
#           mount -a
#         fi
#       EOF
#     }

#     all_in_one_server = {
#       name_suffix            = "all-in-one-server"
#       ami                    = data.aws_ami.amazon_linux.id
#       instance_type          = "c7i.2xlarge"
#       subnet_id              = module.vpc.private_subnet_a_id
#       security_group_ids     = [module.security_groups.all_in_one_server_sg_id]
#       root_volume_size       = 50
#       root_volume_throughput = 250
#       root_volume_iops       = 6000
#       user_data = local.ssm_user_data
#     }
#   }
# }