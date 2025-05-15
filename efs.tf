# EFS
module "efs" {
  source  = "oozou/efs/aws"
  version = "1.0.4"

  prefix                    = var.prefix
  environment               = var.environment
  name                      = "sonarqube"
  encrypted                 = true
  enabled_backup            = var.enabled_backup
  efs_backup_policy_enabled = var.efs_backup_policy_enabled
  access_points = {
    "sonarqube_data" = {
      posix_user = {
        gid            = "5000"
        uid            = "1001"
        secondary_gids = "1002,1003"
      }
      creation_info = {
        gid         = "5000"
        uid         = "1001"
        permissions = "0755"
      }
    }
    "sonarqube_extension" = {
      posix_user = {
        gid            = "5000"
        uid            = "1001"
        secondary_gids = "1002,1003"
      }
      creation_info = {
        gid         = "5000"
        uid         = "1001"
        permissions = "0755"
      }
    }
  }
  vpc_id  = var.vpc_id
  subnets = var.private_subnet_ids

  additional_efs_resource_policies = []
}
