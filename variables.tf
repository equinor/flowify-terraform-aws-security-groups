variable "region" {
  type        = string
  default     = "us-west-1"
  description = "The region where AWS operations will take place"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where to create security group"
}

variable "name_sg" {
  type        = string
  default     = "common"
  description = "Name of security group"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Whether to create a SG for particular environment"
}

variable "env_name" {
  type        = string
  default     = "playground"
  description = "The description that will be applied to the tags for resources created in the SG configuration"
}

variable "description" {
  type        = string
  default     = "Security Group managed by Terraform"
  description = "Description of security group"
}

variable "common_tags" {
  type        = map(string)
  description = "The default tags that will be added to all taggable resources"

  default = {
    EnvClass    = "dev"
    Environment = "Playground"
    Owner       = "Ops"
    Terraform   = "true"
  }
}

variable "ingress_rules" {
  type        = list(string)
  description = "List of ingress rules to create by name"
  default     = []
}

variable "ingress_rules_from_any" {
  type        = list(string)
  description = "List of ingress rules to create by name from 0.0.0.0/0"
  default     = []
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "List of IPv4 CIDR ranges to use on all ingress rules"
  default     = []
}

variable "egress_rules" {
  type        = list(string)
  description = "List of egress rules to create by name"
  default     = []
}

variable "egress_rules_to_any" {
  type        = list(string)
  description = "List of egress rules to create by name to 0.0.0.0/0"
  default     = []
}

variable "egress_cidr_blocks" {
  type        = list(string)
  description = "List of IPv4 CIDR ranges to use on all egress rules"
  default     = []
}

variable "create_ingress_with_cidr_blocks" {
  description = "Whether to create ingress security group rules with cidr blocks"
  type        = bool
  default     = true
}

variable "create_ingress_with_cidr_blocks_from_any" {
  description = "Whether to create ingress security group rules with cidr blocks from any"
  type        = bool
  default     = true
}

variable "create_egress_with_cidr_blocks" {
  description = "Whether to create egress security group rules with cidr blocks"
  type        = bool
  default     = true
}

variable "create_egress_with_cidr_blocks_to_any" {
  description = "Whether to create egress security group rules with cidr blocks to any"
  type        = bool
  default     = true
}

variable "create_ingress_with_source_security_group_id" {
  description = "Whether to create ingress security group rules with source_security_group_id"
  type        = bool
  default     = false
}

variable "create_egress_with_source_security_group_id" {
  description = "Whether to create egress security group rules with source_security_group_id"
  type        = bool
  default     = false
}

variable "ingress_with_source_security_group_id" {
  description = "List of ingress rules to create where 'source_security_group_id' is used"
  type        = list(map(string))
  default     = []
}

variable "egress_with_source_security_group_id" {
  description = "List of egress rules to create where 'source_security_group_id' is used"
  type        = list(map(string))
  default     = []
}

variable "use_setproduct" {
  description = "True to use setproduct of CIDRs and Ports"
  type        = bool
  default     = false
}