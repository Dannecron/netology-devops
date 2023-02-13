Выполнение [домашнего задания](https://github.com/netology-code/clokub-homeworks/blob/clokub-5/15.3.md)
по теме "15.3. Безопасность в облачных провайдерах"

## Q/A

> Используя конфигурации, выполненные в рамках предыдущих домашних заданиях, нужно добавить возможность шифрования бакета.

### Задание 1

Вся конфигурация terraform прописана в директории [terraform](./terraform). Для запуска необходимо скопировать файл
[variables.tf.example](./terraform/variables.tf.example) в [variables.tf](./terraform/variables.tf) и проставить актуальные
значения для всех переменных: `yandex_cloud_id`, `yandex_folder_id`, `yandex_cloud_token`.
Последнее значение можно получить выполнив команду `yc iam create-token`.

> 1. С помощью ключа в KMS необходимо зашифровать содержимое бакета:
> - Создать ключ в KMS

Объект ключа шифрования создаётся следующим описанием:

```terraform
resource "yandex_kms_symmetric_key" "os-cipher-key" {
  name = "os-cipher-key"
}
```

> - С помощью ключа зашифровать содержимое бакета, созданного ранее.

Из [домашнего задания 15.2](/src/homework/15-cloud-providers/15.2) взято описание создания бакета и одного объекта внутри данного бакета.
Для шифрования содержимого необходимо добавить следующий блок к описанию конфигурации `os-netology-bucket`:

```terraform
server_side_encryption_configuration {
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = yandex_kms_symmetric_key.os-cipher-key.id
      sse_algorithm     = "aws:kms"
    }
  }
}
```

PS. При создании подобного бакета загрузка файлов через `terraform` не проходит с ошибкой 403.
Ручная загрузка через web-интерфейс производится корректно. 

> 2. (Выполняется НЕ в terraform) *Создать статический сайт в Object Storage c собственным публичным адресом и сделать доступным по HTTPS
> - Создать сертификат,
> - Создать статическую страницу в Object Storage и применить сертификат HTTPS,
> - В качестве результата предоставить скриншот на страницу с сертификатом в заголовке ("замочек").

После создания бакета (например, с названием `os-netology`, во вкладке "Веб-сайт" необходимо выбрать "Хостинг" и сохранить изменения. Затем во вкладке "Объекты"
нужно загрузить два файла: [index.html](./static/index.html) и [error.html](./static/error.html).
После загрузки можно убедится, что сайт работает, перейдя по ссылке `https://os-netology.website.yandexcloud.net/`.

Чтобы создать свой домен, необходимо следовать [инструкции yandex cloud](https://cloud.yandex.ru/docs/tutorials/web/static?from=int-console-empty-state#configure-dns).

// todo вроде бы всё применилось, но не работает. Так как собственного домена у меня нет,
// то и точно следовать инструкции не представляется возможным.
