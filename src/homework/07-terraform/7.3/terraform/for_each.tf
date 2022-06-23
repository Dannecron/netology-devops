resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}

resource "yandex_compute_instance" "vm-2" {
  for_each = toset(["balancer", "application"])

  name = "test-vm-2"

  resources {
    cores  = local.vm_2_config[each.key].cores[terraform.workspace]
    memory = local.vm_2_config[each.key].memory[terraform.workspace]
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
