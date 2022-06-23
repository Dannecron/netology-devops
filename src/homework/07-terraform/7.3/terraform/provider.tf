terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "netology-tf-state"
    region     = "ru-central1"
    key        = "tf/default.tfstate"
    access_key = "service_account_access_key_id"
    secret_key = "service_account_access_key_secret"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = "auth_token_here"
  cloud_id  = "cloud_id_here"
  folder_id = "folder_id_here"
  zone      = "ru-central1-a"
}
