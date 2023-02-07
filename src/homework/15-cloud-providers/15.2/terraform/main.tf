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

resource "yandex_vpc_network" "os-network" {
  name = "os-network"
}

resource "yandex_vpc_subnet" "os-subnet" {
  name           = "os-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.os-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_iam_service_account" "os-service-account" {
  name = "os-service-account"
}
