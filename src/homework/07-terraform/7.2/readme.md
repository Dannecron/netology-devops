Выполнение [домашнего задания](https://github.com/netology-code/virt-homeworks/blob/master/07-terraform-02-syntax/README.md)
по теме "7.2. Облачные провайдеры и синтаксис Terraform".

## Q/A

### Задание 1

> Вариант с Yandex.Cloud. Регистрация в ЯО и знакомство с основами.
> 
> 1. Подробная инструкция на русском языке содержится [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
> 2. Обратите внимание на период бесплатного использования после регистрации аккаунта.
> 3. Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки
> базового терраформ конфига.
> 4. Воспользуйтесь [инструкцией](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs) на сайте терраформа, что бы
> не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.

Установка и настройка `yc`, а также подключение к `yandex.cloud` подробно разобраны в [домашнем задании 5.4](/src/homework/05-virtualization/5.4/readme.md#задача-1).

Для хранения секретов будет использоваться файл [.env](./terraform/.env), который должен быть инициализирован
перед работой из примера [.env.example](./terraform/.env.example).

### Задание 2

Создание `yandex_compute_instance` через терраформ.

> 1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
> 2. Зарегистрируйте провайдер для [yandex.cloud](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs).
> Подробную инструкцию можно найти [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
> 3. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали
> их в виде переменных окружения.
> 4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.
> 5. В файле `main.tf` создайте ресурс [yandex_compute_image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_image).
> 6. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок.
>
> В качестве результата задания предоставьте:
> 1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?
> 2. Ссылку на репозиторий с исходной конфигурацией терраформа.

Для регистрации провайдера `yandex.cloud` необходимо создать файл [main.tf](./terraform/main.tf) со следующим содержанием:

```terraform
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
```

Здесь конфигурация провайдера будет произведена из переменных окружений, поэтому значения в самом файле не будут реальными.

Следующим шагом необходимо инициализировать конфигурацию:

```shell
cd ./terraform \
	&& env $(cat .env) terraform init
```

Для упрощения вызова команд был создан [Makefile](./Makefile).

Для создания `yandex_compute_image` в [main.tf](./terraform/main.tf) необходимо добавить:

```shell
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "vm-1" {
  name = "test-vm-1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32" # ubuntu-20-04-lts-v20210908
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}
```

Здесь:
- `resource "yandex_vpc_network" "network-1"` - создание сети, необходимой для соединения ВМ с внешними и внутренними ресурсами.
- `resource "yandex_vpc_subnet" "subnet-1"` - создание подсети внутри базовой сети с уже определёнными параметрами и пулом ip-адресов.
- `resource "yandex_compute_instance" "vm-1"` - создание виртуальной машины
  - `initialize_params { image_id = "fd81hgrcv6lsnkremf32" }` идентификатор образа операционной системы.
    Идентификатор можно получить в выводе команды `yc compute image list --folder-id standard-images`,
    которая выводит список всех доступных базовых образов операционных систем.
- `output "internal_ip_address_vm_1"` и `output "external_ip_address_vm_1"` - сохранение данных из объекта виртуальной машины для дальнейшего вывода.

Затем, необходимо выполнить следующую команду, чтобы проверить работоспособность конфигурации:

```shell
cd ./terraform \
  && env  terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.vm-1 will be created
  + resource "yandex_compute_instance" "vm-1" {
<...>
```

#### Ответы

1. При помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami

Для создания своего образа операционной системы для виртуальной машины можно воспользоваться инструментом [`packer`](https://www.packer.io/). 
