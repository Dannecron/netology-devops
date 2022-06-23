Выполнение [домашнего задания](https://github.com/netology-code/virt-homeworks/blob/master/07-terraform-03-basic/README.md)
по теме "7.3. Основы и принцип работы Terraform".

## Q/A

### Задание 1

> Создадим бэкэнд в S3

Документация по подключению бэкенда s3 к `terraform`:
* [настройка terraform](https://www.terraform.io/language/settings/backends/s3)
* [руководство по настройке yandex.cloud](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-state-storage)

Первым шагом необходимо создать сервисный аккаунт по [документации](https://cloud.yandex.ru/docs/iam/operations/sa/create).
Для этого необходимо выполнить следующую команду:

```shell
yc iam service-account create --name my-robot
```

Следующим шагом нужно добавить сервисному аккаунту роль `editor` по [документации](https://cloud.yandex.ru/docs/iam/operations/sa/assign-role-for-sa).

Далее необходимо создать новый ключ доступа. Для этого нужно выполнить команду:

```shell
yc iam access-key create --service-account-name my-robot
```

Из вывода необходимо сохранить значения ключей `key_id` и `secret`, которыми необходимо заполнить 
значения переменных окружения `YC_STORAGE_ACCESS_KEY` и `YC_STORAGE_SECRET_KEY` соответственно.
Для удобства, унесём файл с переменными окружения на верхний уровень: [.env.example](./.env.example) и [.env](./.env).

Затем необходимо создать новый бакет с именем `netology-tf-state` в `Object Storage` по [инструкции](https://cloud.yandex.ru/docs/storage/operations/buckets/create).

После всех приготовлений нужно вынести конфигурацию провайдера в файл [provider.tf](./terraform/provider.tf) и обновить конфигурацию следующим образом:

```terraform
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
```

Как и в прошлый раз, сам провайдер конфигурируется из переменных окружения. При этом настроить `backend` из переменных окружения напрямую невозможно из-за ограничений `terraform`.
Для этого необходимо воспользоваться флагом конфигурации `-backend-config` у команды `terraform init`.
Таким образом, команда инициализации примет вид:

```shell
source .env
cd ./terraform \
    && env $(cat ../.env) terraform init \
        -backend-config="access_key=${YC_STORAGE_ACCESS_KEY}" \
        -backend-config="secret_key=${YC_STORAGE_SECRET_KEY}"
```

### Задание 2

> Инициализируем проект и создаем воркспейсы.
> 
> 1. Выполните `terraform init`:
>   * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3.
>   * иначе будет создан локальный файл со стейтами.
> 2. Создайте два воркспейса `stage` и `prod`.
> 3. В уже созданный `yandex_compute_instance` добавьте зависимость типа инстанса от вокспейса, 
> что бы в разных ворскспейсах использовались разные `instance_type`.
> 5. Добавим `count`. Для `stage` должен создаться один экземпляр, а для `prod` два.
> 6. Создайте рядом еще один `yandex_compute_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
> 7. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
> жизненного цикла `create_before_destroy = true` в один из рессурсов `yandex_compute_instance`.
> 8. При желании поэкспериментируйте с другими параметрами и рессурсами.
>
> В виде результата работы пришлите:
> * Вывод команды `terraform workspace list`.
> * Вывод команды `terraform plan` для воркспейса `prod`.  

// todo
