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
