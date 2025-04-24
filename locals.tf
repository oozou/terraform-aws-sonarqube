locals {
  tags = merge(
    {
      "Environment" = var.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
  name                = format("%s-%s-%s", var.prefix, var.environment, "sonarqube")
  profile_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess", aws_iam_policy.rds_credentials_access_policy.arn]
  security_group_ids  = concat([module.efs.security_group_client_id], [module.sonarqube_postgressql.db_client_security_group_id], var.additional_sg_attacment_ids, var.is_create_security_group ? [aws_security_group.this[0].id] : [])

  default_https_allow_cidr = var.is_enabled_https_public ? ["0.0.0.0/0"] : [data.aws_vpc.this.cidr_block]
  security_group_ingress_rules = merge({
    allow_to_config_sonarqube = {
      port        = "9000"
      cidr_blocks = var.custom_https_allow_cidr != null ? var.custom_https_allow_cidr : local.default_https_allow_cidr
    }
  })

}
