variable "prefix" {
  description = "The prefix name of customer to be displayed in AWS console and resource"
  type        = string
}

variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}

variable "tags" {
  description = "Tags to add more; default tags contian {terraform=true, environment=var.environment}"
  type        = map(string)
  default     = {}
}

variable "instance_type" {
  description = "(Optional) The instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance."
  type        = string
  default     = "t3.small"
}

variable "is_create_security_group" {
  description = "Flag to toggle security group creation"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "The List of the subnet ID to deploy Public Loadbalancer relate to VPC"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "The List of the private subnet ID to deploy instance"
  type        = list(string)
}

variable "database_subnet_ids" {
  description = "The List of the database subnet ID to deploy database"
  type        = list(string)
}


variable "key_name" {
  description = "Key name of the Key Pair to use for the sonarqube instance; which can be managed using"
  type        = string
  default     = null
}

variable "additional_sg_attacment_ids" {
  description = "(Optional) The ID of the security group."
  type        = list(string)
  default     = []
}

variable "ami" {
  type        = string
  description = "(Optional) AMI to use for the instance. Required unless launch_template is specified and the Launch Template specifes an AMI. If an AMI is specified in the Launch Template, setting ami will override the AMI specified in the Launch Template"
  default     = ""
}

variable "public_rule" {
  description = "public rule for run connect sonarqube"
  type = list(object({
    port                  = number
    protocol              = string
    health_check_port     = number
    health_check_protocol = string
  }))
  default = [
    {
      port                  = 9000
      protocol              = "HTTP"
      health_check_port     = 9000
      health_check_protocol = "HTTP"
    }
  ]
}

variable "is_enabled_https_public" {
  description = "if true will enable https to public loadbalancer else enable to private loadbalancer"
  type        = bool
  default     = true
}

variable "custom_https_allow_cidr" {
  description = "cidr block for config sonarqube"
  type        = list(string)
  default     = null
}

variable "enabled_backup" {
  type        = bool
  description = "Enable Backup EFS"
  default     = true
}

variable "efs_backup_policy_enabled" {
  type        = bool
  description = "If `true`, it will turn on automatic backups."
  default     = true
}

variable "enable_ec2_monitoring" {
  description = "Enables/disables detailed monitoring"
  type        = bool
  default     = false
}

variable "alb_certificate_arn" {
  description = "Certitificate ARN to link with ALB"
  type        = string
  default     = ""
}

variable "alb_ssl_policy" {
  description = "ALB ssl policy"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

/* -------------------------------Route 53--------------------------------------- */

variable "is_create_route53_reccord" {
  description = "if true will create route53 reccord for sonarqube"
  type        = bool
  default     = false
}

variable "public_lb_domain" {
  description = "domain of sonarqube"
  type        = string
  default     = "sonarqube"
}


variable "route53_zone_name" {
  description = "This is the name of the hosted zone"
  type        = string
  default     = ""
}

/* -------------------------------------------------------------------------- */
/*                                     RDS                                    */
/* -------------------------------------------------------------------------- */
variable "rds_engine" {
  description = "The database engine to use"
  type        = string
}

variable "rds_engine_version" {
  description = "The engine version to use. If auto_minor_version_upgrade is enabled, you can provide a prefix of the version such as 5.7 (for 5.7.10). The actual engine version used is returned in the attribute engine_version_actual, defined below."
  type        = string
}

variable "rds_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "rds_storage" {
  description = <<EOF
  allocated_storage     >> The allocated storage in gigabytes
  max_allocated_storage >> When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Must be greater than or equal to allocated_storage or leave as default to disable Storage Autoscaling
  storage_type          = "gp3"

  EOF
  type = object({
    allocated_storage     = number
    max_allocated_storage = number
    storage_type          = string
    iops                  = optional(number)
    storage_throughput    = optional(number)
  })
  default = {
    allocated_storage     = 20
    max_allocated_storage = 50
    storage_type          = "gp3"
  }
}

variable "rds_storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
}

variable "rds_credential" {
  description = <<EOF
  username >> (Required unless a snapshot_identifier or replicate_source_db is provided) Username for the master DB user. Cannot be specified for a replica.
  password >> (Required unless a snapshot_identifier or replicate_source_db is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file.
  EOF
  type = object({
    username = string
    password = string
  })
  sensitive = true
}

variable "rds_backup_retention_period" {
  description = "The days to retain backups for. Mostly, for non-production is 7 days and production is 30 days. Default to 7 days"
  type        = number
  default     = 30
}

variable "rds_backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
  type        = string
  default     = null
}

variable "rds_maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
  type        = string
  default     = null
}

variable "rds_deletion_protection" {
  description = "The database can't be deleted when this value is set to true."
  type        = bool
  default     = false
}

variable "rds_enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine): MySQL and MariaDB: audit, error, general, slowquery. PostgreSQL: postgresql, upgrade. MSSQL: agent , error. Oracle: alert, audit, listener, trace."
  type        = list(string)
  default     = []
}

variable "rds_additional_client_security_group_ingress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = list(string)
    source_security_group_id = string
    description              = string
  }))
  description = "Additional ingress rule for client security group."
  default     = []
}

variable "rds_additional_cluster_security_group_ingress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = list(string)
    source_security_group_id = string
    description              = string
  }))
  description = "Additional ingress rule for cluster security group."
  default     = []
}

variable "rds_parameter_family" {
  description = "The database family to use"
  type        = string
}

variable "rds_parameters" {
  description = "A list of DB parameter maps to apply"
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default = []
}