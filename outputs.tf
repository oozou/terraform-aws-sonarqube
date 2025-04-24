output "efs_id" {
  description = "The ID that identifies the file system"
  value       = module.efs.id
}

output "efs_dns_name" {
  description = "The DNS name for the filesystem"
  value       = module.efs.dns_name
}

output "security_group_id" {
  description = "ID of the security group associated to this ec2"
  value       = try(aws_security_group.this[0].id, "")
}

output "security_group_arn" {
  description = "ARN of the security group associated to this ec2"
  value       = try(aws_security_group.this[0].arn, "")
}

output "aws_lb_public_arn" {
  description = "ARN of the application loadbalancer"
  value       = aws_lb.public.arn
}


output "aws_lb_public_zone_id" {
  description = "zone id of the application loadbalancer"
  value       = aws_lb.public.zone_id
}
