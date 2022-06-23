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

Для создания workspace необходимо выполнить две команды:

```shell
cd ./terraform

terraform workspace new stage
Created and switched to workspace "stage"!
<...>

terraform workspace new prod
Created and switched to workspace "prod"!
<...>

terraform workspace list
  default
* prod
  stage
```

Далее, необходимо определить переменные для количества создаваемых виртуальных машин для каждого окружения.
Для этого нужно добавить следующие значения в файл [variables.tf](./terraform/variables.tf):

```terraform
locals {
  vm_count = {
    stage = 1
    prod = 2
  }
}
```

А в [main.tf](./terraform/main.tf) в блоке `vm-1` добавить новый ключ `count = local.vm_count[terraform.workspace]`.

В данном случае, при переключении на `workspace=prod` команда `terraform plan` будет говорить о 4-х ресурсах на изменение.
Но при переключении на `workspace=stage` будет запланировано изменение 3-х ресурсов. 

Далее добавим новую группу виртуальных машин, которые будут создаваться на основе модуля [`for-each`](https://www.terraform.io/language/meta-arguments/for_each), а не `count`.
Для начала добавим конфигурацию в [variables.tf](./terraform/variables.tf):

```terraform
locals {
  vm_2_config = {
    "balancer" = {
      cores = {
        stage = 1
        prod  = 2
      }
      memory = {
        stage = 1
        prod  = 2
      }

    }
    "application" = {
      cores = {
        stage = 1
        prod  = 2
      }
      memory = {
        stage = 1
        prod  = 2
      }

    }
  }
}
```

В данном случае будет производиться инициализация двух машин, для каждой из которых будут определены ресурсы. При этом ресурсы будут зависеть от текущего `workspace`.
Инициализация ресурсов описана в [for_each.tf](./terraform/for_each.tf).
При этом вывод команды `terraform plan` для `workspace=prod` будет выглядеть следующим образом:

```shell
make tf-plan
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.vm-1[0] will be created
  + resource "yandex_compute_instance" "vm-1" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAA
            EOT
        }
      + name                      = "test-vm-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd81hgrcv6lsnkremf32"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm-1[1] will be created
  + resource "yandex_compute_instance" "vm-1" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAA
            EOT
        }
      + name                      = "test-vm-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd81hgrcv6lsnkremf32"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm-2["application"] will be created
  + resource "yandex_compute_instance" "vm-2" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAA
            EOT
        }
      + name                      = "test-vm-2"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd81hgrcv6lsnkremf32"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm-2["balancer"] will be created
  + resource "yandex_compute_instance" "vm-2" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAA
            EOT
        }
      + name                      = "test-vm-2"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd81hgrcv6lsnkremf32"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_vpc_network.network-1 will be created
  + resource "yandex_vpc_network" "network-1" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "network1"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet-1 will be created
  + resource "yandex_vpc_subnet" "subnet-1" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet1"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # yandex_vpc_subnet.subnet-2 will be created
  + resource "yandex_vpc_subnet" "subnet-2" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet2"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.11.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 7 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_vm_1 = [
      + (known after apply),
      + (known after apply),
    ]
  + internal_ip_address_vm_1 = [
      + (known after apply),
      + (known after apply),
    ]

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```
