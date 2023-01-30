Выполнение [домашнего задания](https://github.com/netology-code/clokub-homeworks/blob/clokub-5/15.1/README.md)
по теме "15.1. Организация сети"

## Q/A

> Домашнее задание будет состоять из обязательной части, которую необходимо выполнить на провайдере Яндекс.Облако и дополнительной части в AWS по желанию.
> Все домашние задания в 15 блоке связаны друг с другом и в конце представляют пример законченной инфраструктуры.
> Все задания требуется выполнить с помощью Terraform, результатом выполненного домашнего задания будет код в репозитории.

### Задача 1

> Яндекс.Облако

Вся конфигурация terraform прописана в директории [terraform](./terraform). Для запуска необходимо скопировать файл
[variables.tf.example](./terraform/variables.tf.example) в [variables.tf](./terraform/variables.tf) и проставить актуальные
значения для всех переменных: `yandex_cloud_id`, `yandex_folder_id`, `yandex_cloud_token`.
Последнее значение можно получить выполнив команду `yc iam create-token`.

> 1. Создать VPC.
> - Создать пустую VPC. Выбрать зону.

В качестве зоны выбрана `ru-central1-a`. Для создания новой VPC необходимо добавить следующий конфиг terraform:

```terraform
resource "yandex_vpc_network" "network-vpc" {
  name = "network-vpc"
}
```

> 2. Публичная подсеть.
> - Создать в vpc subnet с названием public, сетью 192.168.10.0/24.

```terraform
resource "yandex_vpc_subnet" "public" {
  name = "subnet-public"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network-vpc.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
```

> - Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1

```terraform
resource "yandex_compute_instance" "nat-instance" {
  name = "nat-instance"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1" # nat-instance-ubuntu-1559218207
      size = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
```

> - Создать в этой публичной подсети виртуалку с публичным IP и подключиться к ней, убедиться что есть доступ к интернету.

```terraform
resource "yandex_compute_instance" "public-instance" {
  name = "public-instance"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3" # ubuntu-20-04-lts-v20220822
      size = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
```

После применения конфигурации `terraform apply` необходимо подключится к `public-instance` через `ssh`:

```shell
ssh ubuntu@<public_external_ip>
```

Чтобы убедиться, что есть доступ в интернет, необходимо сделать `curl` запрос на внешний ресурс, например, `google.com`:

```shell
curl -sS -D - -o /dev/null https://google.com
```

```text
HTTP/2 301
location: https://www.google.com/
<...>
```

> 3. Приватная подсеть.
> - Создать в vpc subnet с названием private, сетью 192.168.20.0/24.

```terraform
resource "yandex_vpc_subnet" "private" {
  name = "subnet_private"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network-vpc.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}
```

> - Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс

```shell
resource "yandex_vpc_route_table" "private_egress" {
  name = "private_egress"
  network_id = yandex_vpc_network.network-vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }
}
```

> - Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее и убедиться что есть доступ к интернету

```terraform
resource "yandex_compute_instance" "private-instance" {
  name = "private-instance"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3" # ubuntu-20-04-lts-v20220822
      size = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
```

После `terraform apply` необходимо сначала подключится к машине `nat-instance` по `ssh`,
а затем произвести подключение к `private-instance` и выполнить `curl` запрос к внешнему ресурсу.

Подключение к приватной машине через `nat-instance` можно произвести одной командой `ssh`, используя ключ `-J`:

```shell
ssh -J ubuntu@<nat_external_ip> ubuntu@<private_internal_ip>

curl -sS -D - -o /dev/null https://google.com
```

```text
todo Что-то идёт не так и запрос не проходит. tracepath виснет на _gateway шаге (сразу после localhost). 
```
