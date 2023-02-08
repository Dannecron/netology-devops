// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "os-storage-editor" {
  folder_id = var.yandex_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.os-service-account.id}"
}

// Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "os-static-key" {
  service_account_id = yandex_iam_service_account.os-service-account.id
  description        = "static access key for object storage"
}

// Создание бакета с использованием ключа
resource "yandex_storage_bucket" "os-netology-bucket" {
  access_key = yandex_iam_service_account_static_access_key.os-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.os-static-key.secret_key
  bucket     = "os-netology-bucket"

  anonymous_access_flags {
    read = true
    list = false
  }
}

resource "yandex_storage_object" "cute-cat-picture" {
  bucket = yandex_storage_bucket.os-netology-bucket.bucket
  access_key = yandex_iam_service_account_static_access_key.os-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.os-static-key.secret_key
  key    = "cute-cat"
  source = "./static/cute_cat.jpg"
  content_type = "image/jpg"
  acl = "public-read"
}

output "os" {
  value = {
    "staticUrl": "https://${yandex_storage_bucket.os-netology-bucket.bucket}.storage.yandexcloud.net/${yandex_storage_object.cute-cat-picture.key}"
  }
}
