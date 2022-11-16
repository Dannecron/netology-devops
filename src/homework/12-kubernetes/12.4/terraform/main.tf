terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "auth_token_here"
  cloud_id  = "cloud_id_here"
  folder_id = "folder_id_here"
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "k8s-control" {
  name = "test-vm-1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32" # ubuntu-20-04-lts-v20210908
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "k8s-node" {
  for_each = toset(["node01", "node02", "node03", "node04"])

  name = each.key

  resources {
    cores  = 1
    memory = 1
  }

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32" # ubuntu-20-04-lts-v20210908
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "control_ips" {
  value = {
    external = yandex_compute_instance.k8s-control.network_interface.0.ip_address
    internal = yandex_compute_instance.k8s-control.network_interface.0.nat_ip_address
  }
}

output "node_ips" {
  value = {
    external = values(yandex_compute_instance.k8s-node)[*].network_interface.0.ip_address
    internal = values(yandex_compute_instance.k8s-node)[*].network_interface.0.nat_ip_address
  }
}
