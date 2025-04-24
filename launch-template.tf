# Launch Configuration Template
module "launch_template" {
  source      = "oozou/launch-template/aws"
  version     = "1.0.3"
  prefix      = var.prefix
  environment = var.environment
  name        = "sonarqube"
  
  user_data = base64encode(templatefile("${path.module}/template/user_data.sh",
    {
      EFS_FS_ID      = module.efs.id,
      DATA_AP_ID     = module.efs.access_point_ids["sonarqube_data"],
      EXT_AP_ID      = module.efs.access_point_ids["sonarqube_extension"],
      RDS_SECRET_ARN = module.sonarqube_postgressql.secret_manager_postgres_creds_arn,
      RDS_ENDPOINT   = module.sonarqube_postgressql.db_instance_endpoint,
      RDS_DB_NAME    = "postgres"
      REGION         = data.aws_region.this.name
  }))
  iam_instance_profile   = { arn : aws_iam_instance_profile.this.arn }
  ami_id                 = var.ami == "" ? data.aws_ami.amazon_linux.id : var.ami
  key_name               = var.key_name
  instance_type          = var.instance_type
  vpc_security_group_ids = local.security_group_ids
  enable_monitoring      = var.enable_ec2_monitoring
  tags                   = local.tags
}
