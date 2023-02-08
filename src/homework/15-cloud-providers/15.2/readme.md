Выполнение [домашнего задания](https://github.com/netology-code/clokub-homeworks/blob/clokub-5/15-2.md)
по теме "15.2. Вычислительные мощности. Балансировщики нагрузки"

## Q/A

> Домашнее задание будет состоять из обязательной части, которую необходимо выполнить на провайдере Яндекс.Облако,
> и дополнительной части в AWS (можно выполнить по желанию). Все домашние задания в 15 блоке связаны друг с другом
> и в конце представляют пример законченной инфраструктуры. Все задания требуется выполнить с помощью Terraform,
> результатом выполненного домашнего задания будет код в репозитории. Перед началом работ следует настроить доступ до облачных ресурсов из Terraform,
> используя материалы прошлых лекций и ДЗ.

### Задание 1

Вся конфигурация terraform прописана в директории [terraform](./terraform). Для запуска необходимо скопировать файл
[variables.tf.example](./terraform/variables.tf.example) в [variables.tf](./terraform/variables.tf) и проставить актуальные
значения для всех переменных: `yandex_cloud_id`, `yandex_folder_id`, `yandex_cloud_token`.
Последнее значение можно получить выполнив команду `yc iam create-token`.

> 1. Создать bucket Object Storage и разместить там файл с картинкой:
> - Создать bucket в Object Storage с произвольным именем;

Для создания бакета необходимо сделать несколько предварительных действий, а именно:
* Создать сервисный аккаунт

    ```terraform
    resource "yandex_iam_service_account" "os-service-account" {
        name = "os-service-account"
    }
    ```

* Назначить сервисному аккаунту роль `editor`

    ```terraform
    resource "yandex_resourcemanager_folder_iam_member" "os-storage-editor" {
      folder_id = var.yandex_folder_id
      role      = "storage.editor"
      member    = "serviceAccount:${yandex_iam_service_account.os-service-account.id}"
    }
    ```

* Создать токен доступа для данного сервисного аккаунта:

    ```terraform
    resource "yandex_iam_service_account_static_access_key" "os-static-key" {
      service_account_id = yandex_iam_service_account.os-service-account.id
      description        = "static access key for object storage"
    }
    ```

После этого можно создать сам бакет:

```terraform
resource "yandex_storage_bucket" "os-netology-bucket" {
  access_key = yandex_iam_service_account_static_access_key.os-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.os-static-key.secret_key
  bucket     = "os-netology-bucket"

  anonymous_access_flags {
    read = true
    list = false
  }
}
```

Блок `anonymous_access_flags` необходим для того, чтобы иметь возможность публичного доступа к загруженным в бакет файлам.

> - Положить в bucket файл с картинкой;

Для загрузки картинки необходимо создать новый объект:

```terraform
resource "yandex_storage_object" "cute-cat-picture" {
  bucket = yandex_storage_bucket.os-netology-bucket.bucket
  access_key = yandex_iam_service_account_static_access_key.os-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.os-static-key.secret_key
  key    = "cute-cat"
  source = "./static/cute_cat.jpg"
  content_type = "image/jpg"
  acl = "public-read"
}
```

> - Сделать файл доступным из Интернет.

После применения конфигурации `terraform` файл будет доступен по ссылке `staticUrl` из `output`.

> 2. Создать группу ВМ в public подсети фиксированного размера с шаблоном LAMP и web-страничкой, содержащей ссылку на картинку из bucket:
> - Создать Instance Group с 3 ВМ и шаблоном LAMP. Для LAMP рекомендуется использовать `image_id = fd827b91d99psvq5fjit`;

Для создания виртуальных машин будет использовано описание объекта [yandex_compute_instance_group](./terraform/lamp.tf).
Основные моменты:

* Объявление, что в группе будет находиться ровно 3 виртуальные машины
    
    ```terraform
    # inside os-lamp-group
    scale_policy {
        fixed_scale {
          size = 3
      }
    }
    ```

* Для подключения группы к подсети необходимо, чтобы сервисному аккаунту была назначена роль `vpc.user`:

    ```terraform
    resource "yandex_resourcemanager_folder_iam_member" "os-vpc-user" {
      folder_id = var.yandex_folder_id
      role      = "vpc.user"
      member    = "serviceAccount:${yandex_iam_service_account.os-service-account.id}"
    }
    ```

* Для создания виртуальных машин необходимо, чтобы сервисному аккаунту была назначена роль `editor`:

    ```terraform
    resource "yandex_resourcemanager_folder_iam_member" "os-global-editor" {
      folder_id = var.yandex_folder_id
      role      = "editor"
      member    = "serviceAccount:${yandex_iam_service_account.os-service-account.id}"
    }
    ```

> - Для создания стартовой веб-страницы рекомендуется использовать раздел `user_data` в [meta_data](https://cloud.yandex.ru/docs/compute/concepts/vm-metadata);
> - Разместить в стартовой веб-странице шаблонной ВМ ссылку на картинку из bucket;

В описании ключа `user_data` используется нотация [`cloud-init`](https://cloudinit.readthedocs.io/en/latest/reference/examples.html).
Таким образом, для начала необходимо создать файл конфигурации [cloud-config.yaml](./terraform/cloud-config.yaml) с содержимым:

```yaml
#cloud-config
write_files:
  - content: |
      <!DOCTYPE html>
      <html lang="en">
        ...
      </html>
    path: "/var/www/html/index2.html"
    owner: root:root
    permissions: 0o664
```

Здесь в content расположено содержимое html-файла, которое будет показано при запросе к web-серверу.

Затем, необходимо добавить чтение данного файла:

```terraform
# inside os-lamp-group.instance_template
metadata = {
  user-data = file("./cloud-config.yaml")
}
```

> - Настроить проверку состояния ВМ.

Для настройки проверки состояния ВМ необходимо в конфигурацию группы добавить объект `healthcheck`:

```terraform
# inside os-lamp-group
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
```

Для проверки будет использована практика из [предыдущего домашнего задания](/src/homework/15-cloud-providers/15.1),
когда для подключения к машинам, которые не имеют выделенного внешнего ip-адреса используется дополнительная виртуальная машина,
доступная из-вне.

Таким образом, необходимо выполнить команды и убедиться, что html-файл был создан и доступен:

```shell
ssh -J ubuntu@<public-ips.external> ubuntu@<lamp-ips.internalLamp>
curl http://localhost/index2.html
```

```text
<!DOCTYPE html>
<html lang="en">
...
</html>
```


> 3. Подключить группу к сетевому балансировщику:
> - Создать сетевой балансировщик;

// todo

```terraform
resource "yandex_lb_network_load_balancer" "os-lamp-balancer" {
  name = "os-lamp-balancer"

  listener {
    name = "os-lamp-balancer-listener"
    port = 80
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.os-lamp-group.id
    healthcheck {
      name = "os-lamp-balancer-healthcheck"
      http_options {
        port = 80
        path = "/index2.html"
      }
    }
  }
}
```

> - Проверить работоспособность, удалив одну или несколько ВМ.

// todo
