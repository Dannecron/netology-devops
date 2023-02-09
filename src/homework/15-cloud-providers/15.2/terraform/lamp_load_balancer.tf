resource "yandex_lb_target_group" "os-lamp-balancer-group" {
  name      = "os-lamp-balancer-group"
  region_id = "ru-central1"

  target {
    subnet_id = yandex_vpc_subnet.os-subnet.id
    address   = yandex_compute_instance_group.os-lamp-group.instances[0].network_interface[0].ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.os-subnet.id
    address   = yandex_compute_instance_group.os-lamp-group.instances[1].network_interface[0].ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.os-subnet.id
    address   = yandex_compute_instance_group.os-lamp-group.instances[2].network_interface[0].ip_address
  }
}

resource "yandex_lb_network_load_balancer" "os-lamp-balancer" {
  name = "os-lamp-balancer"

  listener {
    name = "os-lamp-balancer-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.os-lamp-balancer-group.id
    healthcheck {
      name = "os-lamp-balancer-healthcheck"
      http_options {
        port = 80
        path = "/index2.html"
      }
    }
  }
}

output "balancer-ips" {
  value = {
    external = [for listener in yandex_lb_network_load_balancer.os-lamp-balancer.listener: listener.external_address_spec.*.address].0[0]
  }
}
