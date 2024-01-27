# Security L7
resource "yandex_vpc_security_group" "l7" {
  name        = "security group l7"
  description = "Description for security group"
  network_id  = yandex_vpc_network.vpc-net.id

 egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 1
    to_port        = 65535
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol          = "TCP"
    description       = "healthchecks"
    predefined_target = "loadbalancer_healthchecks"
    port              = 30080
  }
}

# Security bastion
resource "yandex_vpc_security_group" "bastion-sg" {
  name        = "bastion sg"
  description = "Description for security group"
  network_id  = yandex_vpc_network.vpc-net.id

 egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 1
    to_port        = 65535
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

}

# Security web
resource "yandex_vpc_security_group" "web-sg" {
  name        = "web sg"
  description = "Description for security group"
  network_id  = yandex_vpc_network.vpc-net.id

 egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 1
    to_port        = 65535
  }

  ingress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
    from_port      = 1
    to_port        = 65535         
  }

}

# Security zabbix
resource "yandex_vpc_security_group" "zabbix-sg" {
  name        = "zabbix sg"
  description = "Description for security group"
  network_id  = yandex_vpc_network.vpc-net.id

 egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 1
    to_port        = 65535
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8080
  }

  ingress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
    from_port      = 1
    to_port        = 65535         
  }

}

# Security elastic
resource "yandex_vpc_security_group" "elastic-sg" {
  name        = "elastic sg"
  description = "Description for security group"
  network_id  = yandex_vpc_network.vpc-net.id

 egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 1
    to_port        = 65535
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "elastic"
    v4_cidr_blocks = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
    port           = 9200
  }
  
}

# Security Kibana
resource "yandex_vpc_security_group" "kibana-sg" {
  name        = "kibana sg"
  description = "Description for security group"
  network_id  = yandex_vpc_network.vpc-net.id

 egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "kibana"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }
  
  ingress {
    protocol       = "TCP"
    description    = "elastic"
    v4_cidr_blocks = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
    port           = 9200
  }
  
}