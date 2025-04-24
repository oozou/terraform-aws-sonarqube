
/* -------------------------------------------------------------------------- */
/*                               PostgreSQL RDS                               */
/* -------------------------------------------------------------------------- */
module "sonarqube_postgressql" {
  source  = "oozou/rds/aws"
  version = "2.1.3"

  prefix      = var.prefix
  name        = "sonarqube"
  environment = var.environment

  #db instance (server)
  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  #db instance (storage)
  allocated_storage     = var.rds_storage.allocated_storage
  storage_encrypted     = var.rds_storage_encrypted
  max_allocated_storage = var.rds_storage.max_allocated_storage
  storage_type          = var.rds_storage.storage_type
  iops                  = var.rds_storage.iops

  #db instance (schema)
  username = var.rds_credential.username
  password = var.rds_credential.password
  port     = 5432

  #db instance (monitoring)
  is_enable_monitoring                  = true
  monitoring_interval                   = 60
  performance_insights_enabled          = true
  performance_insights_use_cmk          = true
  performance_insights_retention_period = 7

  #db instance (backup)
  maintenance_window         = var.rds_maintenance_window
  backup_window              = var.rds_backup_window
  backup_retention_period    = var.rds_backup_retention_period
  auto_minor_version_upgrade = false

  #db instance (additional)
  skip_final_snapshot = false
  deletion_protection = var.rds_deletion_protection

  #db instance (logging)
  enabled_cloudwatch_logs_exports = var.rds_enabled_cloudwatch_logs_exports

  #security group
  vpc_id                                          = var.vpc_id
  additional_client_security_group_ingress_rules  = var.rds_additional_client_security_group_ingress_rules
  additional_cluster_security_group_ingress_rules = var.rds_additional_cluster_security_group_ingress_rules
  additional_client_security_group_egress_rules = [{
    cidr_blocks              = ["0.0.0.0/0"]
    description              = "allow to any"
    from_port                = -1
    is_cidr                  = true
    is_sg                    = false
    protocol                 = "all"
    source_security_group_id = ""
    to_port                  = -1
  }]

  #parameter group
  family     = var.rds_parameter_family
  parameters = var.rds_parameters

  #subnet group
  subnet_ids = var.database_subnet_ids

  custom_tags = var.tags

}