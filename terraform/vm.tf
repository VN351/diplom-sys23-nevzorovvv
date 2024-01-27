 # Создание Web Server 1
resource "yandex_compute_instance" "vm_web_1" {
  name = "web-server-1"
  hostname = "web-server-1"
  allow_stopping_for_update = true
  platform_id = "standard-v3"
  zone = "ru-central1-a"

  resources {
    cores = 2
    core_fraction = 20
    memory = 4
  }

  scheduling_policy {
  preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd866d9q7rcg6h4udadk" 
      size = "10"
    }
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.vpc-subnet-a.id
    security_group_ids = [yandex_vpc_security_group.web-sg.id]
    ip_address         = "10.1.1.10"
  }
}

# Создание Web Server 2
resource "yandex_compute_instance" "vm_web_2" {
  name        = "web-server-2"
  hostname = "web-server-2"
  allow_stopping_for_update = true
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores = 2
    core_fraction = 20
    memory = 4
  }

   scheduling_policy {
  preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd866d9q7rcg6h4udadk"
      size = "10"
    }
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.vpc-subnet-b.id
    security_group_ids = [yandex_vpc_security_group.web-sg.id]
    ip_address         = "10.1.2.10"
  }
}

# Создание Zabbix server
resource "yandex_compute_instance" "vm_zabbix" {
  name        = "zabbix"
  hostname = "zabbix"
  allow_stopping_for_update = true
  platform_id = "standard-v3"
  zone        = "ru-central1-d"

  resources {
    cores = 2
    core_fraction = 20
    memory = 4
  }

   scheduling_policy {
  preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd866d9q7rcg6h4udadk"
      size = "10"
    }
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.vpc-subnet-d.id
    security_group_ids = [yandex_vpc_security_group.zabbix-sg.id]
    nat = true
    ip_address         = "10.1.4.40"
  }
}
# Создание Elastic server
resource "yandex_compute_instance" "vm_elastic" {
  name        = "elastic"
  hostname = "elastic"
  allow_stopping_for_update = true
  platform_id = "standard-v3"
  zone        = "ru-central1-c"

  resources {
    cores = 2
    core_fraction = 20
    memory = 4
  }

   scheduling_policy {
  preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd866d9q7rcg6h4udadk"
      size = "10"
    }
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.vpc-subnet-c.id
    security_group_ids = [yandex_vpc_security_group.elastic-sg.id]
    ip_address         = "10.1.3.25"
  }
}

# Создание Kibana
resource "yandex_compute_instance" "vm_kibana" {
  name        = "kibana"
  hostname = "kibana"
  allow_stopping_for_update = true
  platform_id = "standard-v3"
  zone        = "ru-central1-d"

  resources {
    cores = 2
    core_fraction = 20
    memory = 4
  }

   scheduling_policy {
  preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd866d9q7rcg6h4udadk"
      size = "10"
    }
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.vpc-subnet-d.id
    security_group_ids = [yandex_vpc_security_group.kibana-sg.id]
    nat = true
    ip_address         = "10.1.4.35"
  }
}

# Создание Bastion host
resource "yandex_compute_instance" "vm_bastion_host" {
  name        = "bastion-host"
  hostname = "bastion-host"
  allow_stopping_for_update = true
  platform_id = "standard-v3"
  zone        = "ru-central1-d"

  resources {
    cores = 2
    core_fraction = 20
    memory = 4
  }

   scheduling_policy {
  preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd866d9q7rcg6h4udadk"
      size = "10"
    }
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.vpc-subnet-d.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.bastion-sg.id]
    ip_address         = "10.1.4.4"
  }
}

# snapshot
resource "yandex_compute_snapshot_schedule" "snapshot" {
  name        = "snapshot"
  description = "everyday"

  schedule_policy {
    expression = "* 3 ? * *"
  }

  snapshot_count = 7

  disk_ids = [
    "${yandex_compute_instance.vm_web_1.boot_disk[0].disk_id}",
    "${yandex_compute_instance.vm_web_2.boot_disk[0].disk_id}",
    "${yandex_compute_instance.vm_zabbix.boot_disk[0].disk_id}",
    "${yandex_compute_instance.vm_elastic.boot_disk[0].disk_id}",
    "${yandex_compute_instance.vm_kibana.boot_disk[0].disk_id}",
    "${yandex_compute_instance.vm_bastion_host.boot_disk[0].disk_id}"
  ]
}

