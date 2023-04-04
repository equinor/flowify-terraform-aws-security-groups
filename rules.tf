variable "rules" {
  description = "Map of security group rules, defined as 'name' = ['from port', 'to port', 'protocol', 'description'])"
  type        = map(any)

  default = {
    # Rules for Any traffic
    any = [0, 0, "-1", "Allow ANY traffic"]
    # Rules for SSH
    tcp-22 = [22, 22, "tcp", "Allow SSH port 22"]
    # Rules for all ports & protocols
    all-traffic   = [-1, -1, "-1", "Allow all protocols"]
    all-tcp       = [0, 65535, "tcp", "Allow all TCP ports"]
    all-udp       = [0, 65535, "udp", "Allow all UDP ports"]
    all-icmp      = [-1, -1, "icmp", "Allow all IPV4 ICMP"]
    all-ipv6-icmp = [-1, -1, 58, "Allow all IPV6 ICMP"]
    # rule for ports to choose from when configuring new vpn server
    vpn-udp  = [45000, 45299, "udp", "Allow UDP ports for VPN"]
    udp-1118 = [1118, 1118, "udp", "Allow UDP ports for VPN"]
    # Rules for main TCP ports 80 and 443
    tcp-80  = [80, 80, "tcp", "Allow HTTP port 80"]
    tcp-443 = [443, 443, "tcp", "Allow HTTPS port 443"]
    # Rules for Databases
    pg-sql-5432 = [5432, 5432, "tcp", "Allow TCP port 5432 for PostgreSQL"]
    mysql-3306  = [3306, 3306, "tcp", "Allow TCP port 3306 for MySQL"]
    # Rules for specific UDP ports
    udp-161  = [161, 161, "udp", "Allow UDP port 161 for SNMP"]
    udp-123  = [123, 123, "udp", "Allow UDP port 123 for pritunl host"]
    # Rules for logging and elasticsearch stack tools
    tcp-9200_9300 = [9200, 9300, "tcp", "Allow TCP ports from 9200 to 9300 for logging and elastic stack tools"]
    tcp-24224     = [24224, 24224, "tcp", "Allow TCP port 24224 for Fluentd logs"]
    # Rules for LDAP
    tcp-636 = [636, 636, "tcp", "Allow TCP port 636 for LDAP"]
    tcp-389 = [389, 389, "tcp", "Allow TCP port 389 for LDAP"]
    tcp-53  = [53,  53,  "tcp", "Allow TCP port 53 for DNS resolving via FreeIPA LDAP"]
    udp-53  = [53,  53,  "udp", "Allow UDP port 53 for DNS resolving via FreeIPA LDAP"]
    # Rules for Redis
    tcp-6379 = [6379, 6379, "tcp", "Allow TCP port 6379 for Redis"]
    # Rules for svcdiscovery host
    tcp-8400      = [8400, 8400, "tcp", "Allow TCP port 8400 for Vault"]
    tcp-8200      = [8200, 8200, "tcp", "Allow TCP port 8200 for Vault"]
    tcp-8201      = [8201, 8201, "tcp", "Allow TCP port 8201 for Vault"]
    tcp-2888      = [2888, 2888, "tcp", "Allow TCP port 2888 for Zookeeper"]
    tcp-3888      = [3888, 3888, "tcp", "Allow TCP port 2888 for Zookeeper"]
    tcp-2181      = [2181, 2181, "tcp", "Allow TCP port 2181 for Zookeeper"]
    udp-8300_8302 = [8300, 8302, "udp", "Allow UDP ports from 8300 to 8302 for Consul"]
    tcp-8300_8302 = [8300, 8302, "tcp", "Allow TCP ports from 8300 to 8302 for Consul"]
    udp-8600      = [8600, 8600, "udp", "Allow UDP port 8600 for Consul"]
    tcp-8600      = [8600, 8600, "tcp", "Allow TCP port 8600 for Consul"]
    tcp-8500      = [8500, 8500, "tcp", "Allow TCP port 8500 for Consul"]
    # Rules for Kubernetes
    kubernetes   = [6443, 6443, "tcp", "Allow TCP port 6443 for kubernetes api"]
    kubelet-api  = [10250, 10250, "tcp", "Allow TCP port 10250 for kubelet api"]
    kube-sched   = [10251, 10251, "tcp", "Allow TCP port 10251 for kube scheduler"]
    kube-control = [10252, 10252, "tcp", "Allow TCP port 10252 for kube controller"]
    kube-read    = [10255, 10255, "tcp", "Allow TCP port 10255 for kube read only"]
    etcd-client  = [2379, 2379, "tcp", "Allow TCP port 2379 for etcd client"]
    etcd-server  = [2380, 2380, "tcp", "Allow TCP port 2380 for etcd server"]
    etcd-listen  = [4001, 4001, "tcp", "Allow TCP port 4001 for etcd listen"]
    # Rules for FreeIPA
    udp-88  = [88, 88, "udp", "Allow UDP port 88 for FreeIPA kerberos instances"]
    udp-464 = [464, 464, "udp", "Allow UDP port 464 for FreeIPA kerberos instances"]
    tcp-464 = [464, 464, "tcp", "Allow TCP port 464 for FreeIPA kerberos instances"]
    # Rules for DocumentDB
    docdb-27017 = [27017, 27017, "tcp", "Allow TCP port 27017 for DocumentDB cluster"]
    # Rules for Jenkins
    tcp-5000      = [5000, 5000, "tcp", "Allow TCP port 5000 for Jenkins"]
    tcp-2376      = [2376, 2376, "tcp", "Allow TCP port 2376 for Jenkins"]
    # Rules for Email services
    smtp-25       = [25, 25, "tcp", "Allow SMTP port 25"]
    pop3-110      = [110, 110, "tcp", "Allow POP3 port 110"]
    imap-143      = [143, 143, "tcp", "Allow IMAP port 143"]
    smtps-465     = [465, 465, "tcp", "Allow SMTPS port 465"]
    smtp-587      = [587, 587, "tcp", "Allow SMTP port 587"]
    imaps-993     = [993, 993, "tcp", "Allow IMAPS port 993"]
    pop3s-995     = [995, 995, "tcp", "Allow POP3S port 995"]
  }
}
