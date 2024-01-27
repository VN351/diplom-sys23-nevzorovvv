# Создание VPC
resource "yandex_vpc_network" "vpc-net" {
  name = "vpc-network" 
} 

# Создание подсетей
resource "yandex_vpc_subnet" "vpc-subnet-a" {
  name           = "subnet-1"
  description    = "subnet-1"
  v4_cidr_blocks = ["10.1.1.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.vpc-net.id}"
  route_table_id = yandex_vpc_route_table.routertb.id
}

resource "yandex_vpc_subnet" "vpc-subnet-b" {
  name           = "subnet-2"
  description    = "subnet-2"
  v4_cidr_blocks = ["10.1.2.0/24"]
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.vpc-net.id}"
  route_table_id = yandex_vpc_route_table.routertb.id
}

resource "yandex_vpc_subnet" "vpc-subnet-c" {
  name           = "subnet-3"
  description    = "subnet-3"
  v4_cidr_blocks = ["10.1.3.0/24"]
  zone           = "ru-central1-c"
  network_id     = "${yandex_vpc_network.vpc-net.id}"
  route_table_id = yandex_vpc_route_table.routertb.id
}

resource "yandex_vpc_subnet" "vpc-subnet-d" {
  name           = "subnet-4"
  description    = "subnet-4"
  v4_cidr_blocks = ["10.1.4.0/24"]
  zone           = "ru-central1-d"
  network_id     = "${yandex_vpc_network.vpc-net.id}"
  route_table_id = yandex_vpc_route_table.routertb.id
}

resource "yandex_vpc_gateway" "nat-gateway" {
  name = "egress-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "routertb" {
  network_id = "${yandex_vpc_network.vpc-net.id}"


  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = "${yandex_vpc_gateway.nat-gateway.id}"
  }
}

# Создание Target Group
resource "yandex_alb_target_group" "tws" {
  name           = "web-server"

  target {
    subnet_id    = yandex_vpc_subnet.vpc-subnet-a.id
    ip_address   = yandex_compute_instance.vm_web_1.network_interface[0].ip_address
  }

  target {
    subnet_id    = yandex_vpc_subnet.vpc-subnet-b.id
    ip_address   = yandex_compute_instance.vm_web_2.network_interface[0].ip_address
  }
}

# Создание Backend Group
resource "yandex_alb_backend_group" "web-backend-group" {
  name                     = "backend-web-server"

  http_backend {
    name                   = "backend-web-server"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.tws.id]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

# Создание HTTP Router
resource "yandex_alb_http_router" "http-router" {
  name          = "http-router"
  labels        = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "virtual-host" {
  name                    = "virtual-host"
  http_router_id          = yandex_alb_http_router.http-router.id
  route {
    name                  = "web"
    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.web-backend-group.id
        timeout           = "60s"
      }
    }
  }
} 

# Создание L7 Балансировщика
resource "yandex_alb_load_balancer" "load-balancer" {
  name = "loadbalancer"
  network_id  = yandex_vpc_network.vpc-net.id
  security_group_ids = [yandex_vpc_security_group.l7.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.vpc-subnet-a.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.vpc-subnet-b.id
    }
  }

  listener {
    name = "listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.http-router.id
      }
    }
  }
}