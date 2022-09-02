output "public_ip_control" {
  value = yandex_compute_instance.control[*].network_interface.0.ip_address
  description = "Публичный IP инстанса control ноды"
}

output "private_ip_control" {
  value = yandex_compute_instance.control[*].network_interface.0.ip_address
  description = "Приватный IP инстанса control ноды"
}

output "public_ip_worker" {
  value = yandex_compute_instance.worker[*].network_interface.0.nat_ip_address
  description = "Публичный IP инстанса worker ноды"
}

output "private_ip_worker" {
  value = yandex_compute_instance.worker[*].network_interface.0.nat_ip_address
  description = "Приватный IP инстанса worker ноды"
} 