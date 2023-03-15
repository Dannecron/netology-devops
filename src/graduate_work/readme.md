## Дипломная работа

Выполнение дипломной работы курса netology DevOps инженер. Оригинал задания доступен по [ссылке](https://github.com/netology-code/devops-diplom-yandexcloud/blob/main/README.md).

Весь код, выполненный по ходу выполнения работы находится в репозиториях на github:
* terraform и ansible: [Dannecron/netology-devops-gw-infra](https://github.com/Dannecron/netology-devops-gw-infra)

### Создание облачной инфраструктуры

[Задание](./tasks.md#создание-облачной-инфраструктуры).

#### Предварительная настройка

Данный параграф описывает выполнения шагов 1-3 из задания. 

Предварительная настройка включает в себя несколько шагов, необходимых для последующей работы с `yandex.cloud` через `terraform`.
Данные шаги выполняются в ручную, но могут быть автоматизированы, например, через `ansible`.

1. Установить утилиту [yc](https://cloud.yandex.ru/docs/cli/quickstart) и подключится к облаку.
2. Создание сервисного аккаунта с ролью `editor` на дефолтной директории облака:

    ```shell
    yc iam service-account create --name terraform-acc
    yc resource-manager folder add-access-binding --name default --role editor --subject "serviceAccount:<accId>"
    ```
    
    где `<accId>` - это уникальный идентификатор нового сервисного аккаунта.
    Затем нужно получить ключ доступа для данного сервисного аккаунта:

    ```shell
    yc iam access-key create --service-account-name terraform-acc --format=json
    ```
3. Создание s3-bucket для хранения состояния `terraform`

    ```shell
    yc storage bucket create --name=dnc-netology-tf-state
    ```

Следующий шаг - инициализация terraform и создание нового workspace. Для инициализации используется команда:

```shell
terraform init \
  -backend-config="bucket=dnc-netology-tf-state" \
  -backend-config="access_key=<service_account_key_id>" \
  -backend-config="secret_key=<service_account_secret_key>"
```

где `<service_account_key_id>` и `<service_account_secret_key>` данные полученные на шаге получения ключа доступа для сервисного аккаунта.

Создание и переключение на новый workspace с названием `prod`:

```shell
terraform workspace new prod
```

Для упрощения процесса был создан ansible-playbook [terraform_init.yml](https://github.com/Dannecron/netology-devops-gw-infra/blob/main/terraform_init.yml).
Чтобы усилить безопасность некоторые переменные были зашифрованы через `ansible-vault`.
Таким образом, для запуска достаточно выполнить команду 

```shell
ansible-playbook --ask-vault-pass -i ansible/terraform_init terraform_init.yml
```

После выполнения данных шагов можно приступать непосредственно к разворачиванию инфрастуктуры через команды terraform.

#### Создание VPC и подсетей через terraform

Для создания VPC и двух подсетей будет использована следующая конфигурация:

```terraform
resource "yandex_vpc_network" "netology-gw-network" {
  name = "netology-gw-network"
}

resource "yandex_vpc_subnet" "netology-gw-subnet-a" {
  name           = "netology-gw-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.netology-gw-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "netology-gw-subnet-b" {
  name           = "netology-gw-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.netology-gw-network.id
  v4_cidr_blocks = ["192.168.15.0/24"]
}
```

Затем нужно последовательно выполнить команды для проверки применения конфигурации в облаке (выполняется из [директории terraform](https://github.com/Dannecron/netology-devops-gw-infra/tree/main/terraform)):

```shell
terraform plan
terraform apply
terraform destroy
```

---

### Создание Kubernetes кластера

[Задание](./tasks.md#создание-Kubernetes-кластера).

/// todo

---

### Создание тестового приложения

[Задание](./tasks.md#создание-тестового-приложения).

[Репозиторий тестового приложения](https://github.com/Dannecron/parcel-example-neko)

/// todo

---

### Подготовка cистемы мониторинга и деплой приложения

[Задание](./tasks.md#подготовка-cистемы-мониторинга-и-деплой-приложения).

/// todo

---

### Установка и настройка CI/CD

[Задание](./tasks.md#установка-и-настройка-CI/CD).

/// todo

---
