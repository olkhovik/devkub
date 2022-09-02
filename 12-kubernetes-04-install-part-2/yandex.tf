provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id                 = var.yandex_cloud_id
  folder_id                = var.yandex_folder_id
  zone                     = var.yandex_compute_default_zone
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
  
  depends_on = [
    null_resource.folder
  ]
}

resource "yandex_compute_instance" "control" {
  count     = var.control_count
  name      = "n124-control-${count.index}"
  hostname    = "n124-control-${count.index}.local"

  platform_id = "standard-v1"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-hdd"
      size     = "50"
    }
  }

  network_interface {
    subnet_id = var.yandex_subnet_id
    nat       = true
    ipv6      = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "worker" {
  count     = var.worker_count
  name      = "n124-worker-${count.index}"
  hostname    = "n124-worker-${count.index}.local"

  platform_id = "standard-v1"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-hdd"
      size     = "100"
    }
  }

  network_interface {
    subnet_id = var.yandex_subnet_id
    nat       = true
    ipv6      = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  }