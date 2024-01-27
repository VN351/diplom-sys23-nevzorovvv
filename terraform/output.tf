#Получене ip адресов для вртуальных машин
output "load_balancer_ip_address" {
  value = yandex_alb_load_balancer.load-balancer.listener[0].endpoint[0].address[0].external_ipv4_address
}

output "external_ip_address_vm_zabbix" {
  value = yandex_compute_instance.vm_zabbix.network_interface.0.nat_ip_address
}

output "external_ip_address_vm_kibana" {
  value = yandex_compute_instance.vm_kibana.network_interface.0.nat_ip_address
}

output "external_ip_address_vm_bastion_host" {
  value = yandex_compute_instance.vm_bastion_host.network_interface.0.nat_ip_address
}

