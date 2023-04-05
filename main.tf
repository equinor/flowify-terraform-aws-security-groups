#######################################
# SG Terraform Module                 #
# Valid for both Tf 0.12.29 and 1.1.5 #
#######################################

provider "aws" {
  region = var.region
}

resource "aws_security_group" "this" {
  name        = "${var.env_name}-${var.name_sg}"
  count       = var.enabled == true ? 1 : 0
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      "Name" = "${var.env_name}-${var.name_sg}-sg"
    },
  )
}

##########################
# Ingress - List of rules
##########################
# Security group rules with "cidr_blocks" and it uses list of rules names
locals {
  cidr_ingress_rules          = setproduct(var.ingress_cidr_blocks, var.ingress_rules)
  cidr_egress_rules           = setproduct(var.egress_cidr_blocks, var.egress_rules)
}

resource "aws_security_group_rule" "ingress_rules" {
  count = var.create_ingress_with_cidr_blocks && var.enabled ? var.use_setproduct ? length(local.cidr_ingress_rules) : length(var.ingress_rules) : 0

  security_group_id = aws_security_group.this[0].id
  type              = "ingress"

  cidr_blocks = var.use_setproduct == true ? [local.cidr_ingress_rules[count.index][0]] : var.ingress_cidr_blocks

  from_port   = var.use_setproduct == true ? element(var.rules[local.cidr_ingress_rules[count.index][1]], 0) : element(var.rules[var.ingress_rules[count.index]], 0)
  to_port     = var.use_setproduct == true ? element(var.rules[local.cidr_ingress_rules[count.index][1]], 1) : element(var.rules[var.ingress_rules[count.index]], 1)
  protocol    = var.use_setproduct == true ? element(var.rules[local.cidr_ingress_rules[count.index][1]], 2) : element(var.rules[var.ingress_rules[count.index]], 2)
  description = var.use_setproduct == true ? element(var.rules[local.cidr_ingress_rules[count.index][1]], 3) : element(var.rules[var.ingress_rules[count.index]], 3)
}

resource "aws_security_group_rule" "ingress_rules_from_any" {
  count = var.create_ingress_with_cidr_blocks_from_any && var.enabled ? length(var.ingress_rules_from_any) : 0

  security_group_id = aws_security_group.this[0].id
  type              = "ingress"

  cidr_blocks = ["0.0.0.0/0"]

  from_port   = element(var.rules[var.ingress_rules_from_any[count.index]], 0)
  to_port     = element(var.rules[var.ingress_rules_from_any[count.index]], 1)
  protocol    = element(var.rules[var.ingress_rules_from_any[count.index]], 2)
  description = element(var.rules[var.ingress_rules_from_any[count.index]], 3)
}

#########################
# Egress - List of rules
#########################
# Security group rules with "cidr_blocks" and it uses list of rules names
resource "aws_security_group_rule" "egress_rules" {
  count = var.create_egress_with_cidr_blocks && var.enabled ? var.use_setproduct ? length(local.cidr_egress_rules) : length(var.egress_rules) : 0

  security_group_id = aws_security_group.this[0].id
  type              = "egress"

  cidr_blocks = var.use_setproduct == true ? [local.cidr_egress_rules[count.index][0]] : var.egress_cidr_blocks

  from_port   = var.use_setproduct == true ? element(var.rules[local.cidr_egress_rules[count.index][1]], 0) : element(var.rules[var.egress_rules[count.index]], 0)
  to_port     = var.use_setproduct == true ? element(var.rules[local.cidr_egress_rules[count.index][1]], 1) : element(var.rules[var.egress_rules[count.index]], 1)
  protocol    = var.use_setproduct == true ? element(var.rules[local.cidr_egress_rules[count.index][1]], 2) : element(var.rules[var.egress_rules[count.index]], 2)
  description = var.use_setproduct == true ? element(var.rules[local.cidr_egress_rules[count.index][1]], 3) : element(var.rules[var.egress_rules[count.index]], 3)
}

resource "aws_security_group_rule" "egress_rules_to_any" {
  count = var.create_egress_with_cidr_blocks_to_any && var.enabled ? length(var.egress_rules_to_any) : 0

  security_group_id = aws_security_group.this[0].id
  type              = "egress"

  cidr_blocks = ["0.0.0.0/0"]

  from_port   = element(var.rules[var.egress_rules_to_any[count.index]], 0)
  to_port     = element(var.rules[var.egress_rules_to_any[count.index]], 1)
  protocol    = element(var.rules[var.egress_rules_to_any[count.index]], 2)
  description = element(var.rules[var.egress_rules_to_any[count.index]], 3)
}

##########################
# Ingress - Maps of rules
##########################
# Security group rules with "source_security_group_id", but without "cidr_blocks"
resource "aws_security_group_rule" "ingress_with_source_security_group_id" {
  count = var.create_ingress_with_source_security_group_id && var.enabled ? length(var.ingress_with_source_security_group_id) : 0

  security_group_id = aws_security_group.this[0].id
  type              = "ingress"

  source_security_group_id = var.ingress_with_source_security_group_id[count.index]["source_security_group_id"]

  from_port   = lookup(var.ingress_with_source_security_group_id[count.index], "from_port",   var.rules[lookup(var.ingress_with_source_security_group_id[count.index], "rule", "_", )][0], )
  to_port     = lookup(var.ingress_with_source_security_group_id[count.index], "to_port",     var.rules[lookup(var.ingress_with_source_security_group_id[count.index], "rule", "_", )][1], )
  protocol    = lookup(var.ingress_with_source_security_group_id[count.index], "protocol",    var.rules[lookup(var.ingress_with_source_security_group_id[count.index], "rule", "_", )][2], )
  description = lookup(var.ingress_with_source_security_group_id[count.index], "description", var.rules[lookup(var.ingress_with_source_security_group_id[count.index], "rule", "_", )][3], )
}

#########################
# Egress - Maps of rules
#########################
# Security group rules with "source_security_group_id", but without "cidr_blocks"
resource "aws_security_group_rule" "egress_with_source_security_group_id" {
  count = var.create_egress_with_source_security_group_id && var.enabled ? length(var.egress_with_source_security_group_id) : 0

  security_group_id = aws_security_group.this[0].id
  type              = "egress"

  source_security_group_id = var.egress_with_source_security_group_id[count.index]["source_security_group_id"]

  from_port   = lookup(var.egress_with_source_security_group_id[count.index], "from_port",   var.rules[lookup(var.egress_with_source_security_group_id[count.index], "rule", "_", )][0], )
  to_port     = lookup(var.egress_with_source_security_group_id[count.index], "to_port",     var.rules[lookup(var.egress_with_source_security_group_id[count.index], "rule", "_", )][1], )
  protocol    = lookup(var.egress_with_source_security_group_id[count.index], "protocol",    var.rules[lookup(var.egress_with_source_security_group_id[count.index], "rule", "_", )][2], )
  description = lookup(var.egress_with_source_security_group_id[count.index], "description", var.rules[lookup(var.egress_with_source_security_group_id[count.index], "rule", "_", )][3], )
}
