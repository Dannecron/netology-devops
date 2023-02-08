resource "yandex_compute_instance" "os-public-instance" {
  name = "public-instance"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3" # ubuntu-20-04-lts-v20220822
      size = "10"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.os-subnet.id
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "public-ips" {
  value = {
    external = yandex_compute_instance.os-public-instance.network_interface.0.nat_ip_address
    internal = yandex_compute_instance.os-public-instance.network_interface.0.ip_address
  }
}
