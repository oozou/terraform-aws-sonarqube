module "sonarqube" {
  source = "../../"

  prefix      = "test"
  environment = "dev"

  vpc_id             = "vpc-0d4a8318e598f784b"
  public_subnet_ids  = ["subnet-00d57ebe1db48585b", "subnet-062e5cadad73d060d"]
  private_subnet_ids = ["subnet-0c3051ba16598f822","subnet-0a1136b6f7b46a145"]
  database_subnet_ids = ["subnet-05899160466780f4f", "subnet-0063d593da3e26b5d"]

  instance_type           = "t3a.small"
  public_lb_domain    = "sonarqube"
  is_enabled_https_public = true


  rds_engine         = "postgres"
  rds_engine_version = "17.2"
  rds_instance_class = "db.t3.micro"
  rds_storage = {
    allocated_storage     = 20
    max_allocated_storage = 50
    storage_type          = "gp3"
  }
  rds_storage_encrypted                               = true
  rds_backup_retention_period                         = 7
  rds_backup_window                                   = "03:00-04:00"
  rds_maintenance_window                              = "Sat:04:00-Sat:05:00"
  rds_deletion_protection                             = false
  rds_enabled_cloudwatch_logs_exports                 = ["postgresql", "upgrade"]
  rds_additional_cluster_security_group_ingress_rules = []
  rds_parameter_family                                = "postgres17"

  rds_credential = {
    username = "sonarqube",
    password = "test123xxx"
  }

  alb_certificate_arn = "arn:aws:acm:ap-southeast-1:855546030651:certificate/ee136da9-44c6-467a-8c5c-698e04ef7b1b"

  tags = var.tags
}
