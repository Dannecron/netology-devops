terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yandex_cloud_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "network-vpc" {
  name = "network-vpc"
}

resource "yandex_vpc_subnet" "public" {
  name = "subnet-public"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network-vpc.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private" {
  name = "subnet_private"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network-vpc.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.private_egress.id
}

resource "yandex_vpc_route_table" "private_egress" {
  name = "private_egress"
  network_id = yandex_vpc_network.network-vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }
}

resource "yandex_compute_instance" "nat-instance" {
  name = "nat-instance"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1" # nat-instance-ubuntu-1559218207
      size = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "public-instance" {
  name = "public-instance"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3" # ubuntu-20-04-lts-v20220822
      size = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "private-instance" {
  name = "private-instance"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3" # ubuntu-20-04-lts-v20220822
      size = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "ips" {
  value = {
    nat_internal_ip = yandex_compute_instance.nat-instance.network_interface.0.ip_address
    nat_external_ip = yandex_compute_instance.nat-instance.network_interface.0.nat_ip_address
    public_internal_ip = yandex_compute_instance.public-instance.network_interface.0.ip_address
    public_external_ip = yandex_compute_instance.public-instance.network_interface.0.nat_ip_address
    private_internal_ip = yandex_compute_instance.private-instance.network_interface.0.ip_address
  }
}
