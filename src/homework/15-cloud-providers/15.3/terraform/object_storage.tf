// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "os-storage-editor" {
  folder_id = var.yandex_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.os-service-account.id}"
}

// Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "os-static-key" {
  depends_on = [yandex_resourcemanager_folder_iam_member.os-storage-editor]

  service_account_id = yandex_iam_service_account.os-service-account.id
  description        = "static access key for object storage"
}

// Создание ключа шифрования
resource "yandex_kms_symmetric_key" "os-cipher-key" {
  name = "os-cipher-key"
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

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.os-cipher-key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
