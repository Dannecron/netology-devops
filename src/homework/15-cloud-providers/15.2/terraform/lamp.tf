// Назначение ролей сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "os-vpc-user" {
  folder_id = var.yandex_folder_id
  role      = "vpc.user"
  member    = "serviceAccount:${yandex_iam_service_account.os-service-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "os-global-editor" {
  folder_id = var.yandex_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.os-service-account.id}"
}

resource "yandex_compute_instance_group" "os-lamp-group" {
  name = "os-lamp-group"
  service_account_id = yandex_iam_service_account.os-service-account.id

  depends_on = [
    yandex_resourcemanager_folder_iam_member.os-global-editor,
    yandex_resourcemanager_folder_iam_member.os-vpc-user
  ]

  deletion_protection = false

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_expansion   = 0
    max_unavailable = 1
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  instance_template {
    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit" # lamp-1579613975
        size = "10"
      }
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.os-subnet.id]
    }

    resources {
      cores  = 2
      memory = 2
    }

    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
      user-data = file("./cloud-config.yaml")
    }
  }

  health_check {
    interval = 5
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
    http_options {
      path = "/index.html"
      port = 80
    }
  }
}

output "lamp-ips" {
  value = {
    internalLamp = yandex_compute_instance_group.os-lamp-group.instances.*.network_interface.0.ip_address
  }
}
