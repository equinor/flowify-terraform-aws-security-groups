# AWS Security Groups Terraform module

Author: [Yurii Onuk](https://onuk.org.ua)

Terraform module which creates [EC2 security group within VPC](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) on AWS.

Next types of resources are supported:

* [AWS Security Group](https://www.terraform.io/docs/providers/aws/r/security_group.html)
* [AWS Security Group rule](https://www.terraform.io/docs/providers/aws/r/security_group_rule.html)

## Terraform version compatibility

- 0.12.29
- 1.1.5

# Usage

```hcl-terraform
##############################################################
# COMMON composed VALUES shared across the different modules #
##############################################################
locals {
  app_environment_triplet = terraform.workspace
  common_tags = {
    EnvClass    = var.env_class
    Environment = var.env_name
    Owner       = var.env_owner
    Terraform   = "true"
  }
  env_name_id  = var.env_name
  env_class_id = var.env_class
}
```
## 1. An example of using a module with CIDR_BLOCKS 

main.tf:

```hcl-terraform
module "cidr_blocks_sg" {
  source                 = "git@github.com:equinor/flowify-terraform-aws-security-groups.git/?ref=x.x.x"
  enabled                = lookup(var.cidr_locks_sg_enabled, local.app_environment_triplet)
  region                 = var.region
  name_sg                = "${local.env_class_id}-cidr-blocks"
  env_name               = local.env_name_id
  vpc_id                 = module.vpc.vpc_id

  # Ingress with CIDR blocks
  ingress_rules          = ["tcp-80", "tcp-443"]        # Open access for something 
  ingress_cidr_blocks    = [module.vpc.vpc_cidr_block]  # Access only from VPC subnets
  ingress_rules_from_any = []

  # Egress with CIDR blocks
  egress_rules           = []
  egress_cidr_blocks     = []
  egress_rules_to_any    = ["any"]

  # Tags
  common_tags            = local.common_tags
}
```

## 2. An example of using a module with SOURCE_SECURITY_GROUP_ID and CIDR_BLOCKS

main.tf:

```hcl-terraform
module "source_security_group_id_with_cidr_block_sg" {
  source   = "git@github.com:equinor/flowify-terraform-aws-security-groups.git/?ref=x.x.x"
  enabled  = lookup(var.cidr_locks_sg_enabled, local.app_environment_triplet)
  region   = var.region
  name_sg  = "${local.env_class_id}-source-security-group-id"
  env_name = local.env_name_id
  vpc_id   = module.vpc.vpc_id

  create_ingress_with_cidr_blocks          = false
  create_ingress_with_cidr_blocks_from_any = false

  # Egress with CIDR blocks
  egress_rules        = []
  egress_cidr_blocks  = []
  egress_rules_to_any = ["any"]

  # Ingress with source_security_group_id
  create_ingress_with_source_security_group_id = true

  ingress_with_source_security_group_id = [
    {
      rule                     = "tcp-80"
      source_security_group_id = module.cidr_blocks_sg.security_group_id
    },
    {
      rule                     = "tcp-443"
      source_security_group_id = module.cidr_blocks_sg.security_group_id
    },
  ]

  # Tags
  common_tags = local.common_tags
}
```

## 3. An example of using a module with SOURCE_SECURITY_GROUP_ID

main.tf:

```hcl-terraform
module "source_security_group_id_sg" {
  source   = "git@github.com:equinor/flowify-terraform-aws-security-groups.git/?ref=x.x.x"
  enabled  = lookup(var.cidr_locks_sg_enabled, local.app_environment_triplet)
  region   = var.region
  name_sg  = "${local.env_class_id}-source-security-group-id"
  env_name = local.env_name_id
  vpc_id   = module.vpc.vpc_id

  create_ingress_with_cidr_blocks          = false
  create_ingress_with_cidr_blocks_from_any = false
  create_egress_with_cidr_blocks           = false
  create_egress_with_cidr_blocks_to_any    = false

  # Ingress with source_security_group_id
  create_ingress_with_source_security_group_id = true

  ingress_with_source_security_group_id = [
    {
      rule                     = "tcp-80"
      source_security_group_id = module.cidr_blocks_sg.security_group_id
    },
    {
      rule                     = "tcp-443"
      source_security_group_id = module.cidr_blocks_sg.security_group_id
    },
  ]

  # Egress with source_security_group_id
  create_egress_with_source_security_group_id = true

  egress_with_source_security_group_id = [
    {
      rule                     = "any"
      source_security_group_id = module.cidr_blocks_sg.security_group_id
    },
  ]

  # Tags
  common_tags = local.common_tags
}
```

outputs.tf:

```hcl-terraform
output "security_group_id" {
  value = module.common.security_group_id
}
```

variable.tf:

```hcl-terraform
variable "name_sg" {
  type        = "string"
  default     = "common"
  description = "Name of security group"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Whether to create a SG for particular environment"
}

variable "env_name" {
  type        = "string"
  description = "The description that will be applied to the tags for resources created in the vpc configuration"
  default     = "playground"
}

variable "description_sg" {
  type        = "string"
  default     = "Security Group managed by Terraform"
  description = "Description of security group"
}

variable "common_tags" {
  type = "map"
  default = {
    EnvClass    = "dev"
    Environment = "Playground"
    Owner       = "Ops"
    Terraform   = "true"
  }
  description = "A default map of tags to add to all resources"
}
```

terraform.tfvars:

```hcl-terraform
#########################
# Backend configuration #
#########################

# AWS Regions
region = "us-west-2"

# Add environment owner to tags
env_owner = "DevOps"
```

## Inputs

 Variable                                      | Type                | Default                               | Required | Purpose
:--------------------------------------------- |:-------------------:| ------------------------------------- | -------- | :----------------------
`rules`                                        | `map`               | `See the table below`                 |   `no`   | `Map of security group rules, defined as 'name' = ['from port', 'to port', 'protocol', 'description'])".Default security groups specified in rules.tf. This variables can be redefined in *.tfvars` |
`name_sg`                                      | `string`            | `common`                              |   `no`   | `Name of security group` |
`enabled`                                      | `bool`              | `true`                                |   `no`   | `Whether to create SG for particular environment` |
`description_sg`                               | `string`            | `Security Group managed by Terraform` |   `no`   | `Description of security group` |
`env_name`                                     | `string`            | `playground`                          |   `no`   | `The description that will be applied to the tags for resources created in the vpc configuration` |
`vpc_id`                                       | `string`            | `no`                                  |   `no`   | `ID of the VPC where to create security group` |
`ingress_rules_from_any`                       | `list`              | `[]`                                  |   `no`   | `List of ingress rules to create by name from 0.0.0.0/0` |
`egress_rules_to_any`                          | `list`              | `[]`                                  |   `no`   | `List of egress rules to create by name to 0.0.0.0/0` |
`ingress_rules`                                | `list`              | `[]`                                  |   `no`   | `List of ingress rules to create by name` |
`ingress_cidr_blocks`                          | `list`              | `[]`                                  |   `no`   | `List of IPv4 CIDR ranges to use on all ingress rules. Specified if` **ingress_rules** `is specified.` |
`egress_rules`                                 | `list`              | `[]`                                  |   `no`   | `List of egress rules to create by name` |
`egress_cidr_blocks`                           | `list`              | `[]`                                  |   `no`   | `List of IPv4 CIDR ranges to use on all egress rules. Specified if` **egress_rules** `is specified.` |
`create_ingress_with_cidr_blocks`              | `bool`              | `true`                                |   `no`   | `Whether to create ingress security group rules with cidr blocks` |
`create_ingress_with_cidr_blocks_from_any`     | `bool`              | `true`                                |   `no`   | `Whether to create ingress security group rules with cidr blocks from any`
`create_egress_with_cidr_blocks`               | `bool`              | `true`                                |   `no`   | `Whether to create egress security group rules with cidr blocks`
`create_egress_with_cidr_blocks_to_any`        | `bool`              | `true`                                |   `no`   | `Whether to create egress security group rules with cidr blocks to any`
`create_ingress_with_source_security_group_id` | `bool`              | `false`                               |   `no`   | `Whether to create ingress security group rules with source_security_group_id`
`create_egress_with_source_security_group_id`  | `bool`              | `false`                               |   `no`   | `Whether to create egress security group rules with source_security_group_id`
`ingress_with_source_security_group_id`        | `list(map(string))` | `[]`                                  |   `no`   | `List of ingress rules to create where 'source_security_group_id' is used`
`egress_with_source_security_group_id`         | `list(map(string))` | `[]`                                  |   `no`   | `List of egress rules to create where 'source_security_group_id' is used`
`common_tags`                                  | `map`               | `EnvClass = "dev",Environment = "Playground", Owner = "Ops", Terraform = "true"` | `no` | `The common tags that will be added to all taggable resources` |

## Outputs

| Name                        | Description                         |
| --------------------------- | ----------------------------------- |
| `security_group_id`         | `The ID of the security group`      |

## Port rules description

| Name            | From_port | To_port | Protocol | Description         |
| --------------- | --------- | ------- | -------- | ------------------- |
| `any`           | `0`       | `0`     | `-1`     | `Allow ANY traffic` |
| `tcp-22`        | `22`      | `22`    | `tcp`    | `Allow SSH port 22` |
| `all-traffic`   | `-1`      | `-1`    | `-1`     | `Allow all protocols` |
| `all-tcp`       | `0`       | `65535` | `tcp`    | `Allow all TCP ports` |
| `all-udp`       | `0`       | `65535` | `udp`    | `Allow all UDP ports` |
| `all-icmp`      | `-1`      | `-1`    | `icmp`   | `Allow all IPV4 ICMP` |
| `all-ipv6-icmp` | `-1`      | `-1`    | `58`     | `Allow all IPV6 ICMP` |
| `tcp-80`        | `80`      | `80`    | `tcp`    | `Allow HTTP port 80` |
| `tcp-443`       | `443`     | `443`   | `tcp`    | `Allow HTTPS port 443` |
| `pg-sql-5432`   | `5432`    | `5432`  | `tcp`    | `Allow TCP port 5432 for PostgreSQL` |
| `mysql-3306`    | `3306`    | `3306`  | `tcp`    | `Allow TCP port 3306 for MySQL` |
| `udp-161`       | `161`     | `161`   | `udp`    | `Allow UDP port 161 for SNMP` |
| `udp-1118`      | `1118`    | `1118`  | `udp`    | `Allow UDP port 1118 for VPN` |
| `udp-123`       | `123`     | `123`   | `udp`    | `Allow UDP port 123 for pritunl host` |
| `tcp-9200_9300` | `9200`    | `9300`  | `tcp`    | `Allow TCP ports from 9200 to 9300 for logging and elastic stack tools` |
| `tcp-24224`     | `24224`   | `24224` | `tcp`    | `Allow TCP port 24224 for Fluentd logs` |
| `tcp-636`       | `636`     | `636`   | `tcp`    | `Allow TCP port 636 for LDAP` |
| `tcp-53`        | `53`      | `53`    | `tcp`    | `Allow TCP port 53 for DNS resolving via FreeIPA LDAP` |
| `udp-53`        | `53`      | `53`    | `udp`    | `Allow UDP port 53 for DNS resolving via FreeIPA LDAP` |
| `tcp-389`       | `389`     | `389`   | `tcp`    | `Allow TCP port 389 for LDAP` |
| `tcp-6379`      | `6379`    | `6379`  | `tcp`    | `Allow TCP port 6379 for Redis` |
| `tcp-8400`      | `8400`    | `8400`  | `tcp`    | `Allow TCP port 8400 for Vault` |
| `tcp-8200`      | `8200`    | `8200`  | `tcp`    | `Allow TCP port 8200 for Vault` |
| `tcp-2888`      | `2888`    | `2888`  | `tcp`    | `Allow TCP port 2888 for Zookeeper` |
| `tcp-3888`      | `3888`    | `3888`  | `tcp`    | `Allow TCP port 2888 for Zookeeper` |
| `tcp-2181`      | `2181`    | `2181`  | `tcp`    | `Allow TCP port 2181 for Zookeeper` |
| `udp-8300_8302` | `8300`    | `8302`  | `udp`    | `Allow UDP ports from 8300 to 8302 for Consul` |
| `tcp-8300_8302` | `8300`    | `8302`  | `tcp`    | `Allow TCP ports from 8300 to 8302 for Consul` |
| `udp-8600`      | `8600`    | `8600`  | `udp`    | `Allow UDP port 8600 for Consul` |
| `tcp-8600`      | `8600`    | `8600`  | `tcp`    | `Allow TCP port 8600 for Consul` |
| `tcp-8500`      | `8500`    | `8500`  | `tcp`    | `Allow TCP port 8500 for Consul` |
| `tcp-514`       | `514`     | `514`   | `tcp`    | `Allow TCP port 514 for Syslog`  |
| `kubernetes`    | `6443`    | `6443`  | `tcp`    | `Allow TCP port 6443 for kubernetes api` |
| `kubelet-api`   | `10250`   | `10250` | `tcp`    | `Allow TCP port 10250 for kubelet api` |
| `kube-sched`    | `10251`   | `10251` | `tcp`    | `Allow TCP port 10251 for kube scheduler` |
| `kube-control`  | `10252`   | `10252` | `tcp`    | `Allow TCP port 10252 for kube controller` |
| `kube-read`     | `10255`   | `10255` | `tcp`    | `Allow TCP port 10255 for kube read only` |
| `etcd-client`   | `2379`    | `2379`  | `tcp`    | `Allow TCP port 2379 for etcd client` |
| `etcd-server`   | `2380`    | `2380`  | `tcp`    | `Allow TCP port 2380 for etcd server` |
| `etcd-listen`   | `4001`    | `4001`  | `tcp`    | `Allow TCP port 4001 for etcd listen` |
| `udp-88`        | `80`      | `88`    | `udp`    | `Allow UDP port 88 for FreeIPA kerberos instances` |
| `udp-464`       | `464`     | `464`   | `udp`    | `Allow UDP port 464 for FreeIPA kerberos instances` |
| `tcp-464`       | `464`     | `464`   | `tcp`    | `Allow TCP port 464 for FreeIPA kerberos instances` |
| `tcp-5000`      | `5000`    | `5000`  | `tcp`    | `Allow TCP port 5000 for Jenkins` |
| `tcp-2376`      | `2376`    | `2376`  | `tcp`    | `Allow TCP port 2376 for Jenkins` |

## Terraform Validate Action

Runs `terraform validate -var-file=validator` to validate the Terraform files 
in a module directory via CI/CD pipeline.
Validation includes a basic check of syntax as well as checking that all variables declared.

### Success Criteria

This action succeeds if `terraform validate -var-file=validator` runs without error.

### Validator

If some variables are not set as default, we should fill the file `validator` with these variables.
