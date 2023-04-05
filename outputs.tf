output "security_group_id" {
  description = "The ID of the security group"
  value       = var.enabled ? aws_security_group.this[0].id : ""
}

