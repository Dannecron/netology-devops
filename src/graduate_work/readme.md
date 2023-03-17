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

Конфигурация машин будет одинаковая, поэтому terraform-конфигурация будет выглядеть следующим образом:

```terraform
resource "random_shuffle" "netology-gw-subnet-random" {
  input        = [yandex_vpc_subnet.netology-gw-subnet-a.id, yandex_vpc_subnet.netology-gw-subnet-b.id]
  result_count = 1
}

resource "yandex_compute_instance" "k8s-cluster" {
  for_each = toset(["control", "node01", "node2"])

  name = each.key

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
    subnet_id = random_shuffle.netology-gw-subnet-random.result[0]
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "cluster_ips" {
  value = {
    internal = values(yandex_compute_instance.k8s-cluster)[*].network_interface.0.ip_address
    external = values(yandex_compute_instance.k8s-cluster)[*].network_interface.0.nat_ip_address
  }
}
```

Для распределения по разным зонам доступности использован ресурс `random_shuffle`.

После деплоя инфраструктуры необходимо скачать репозиторий [kubespray](https://github.com/kubernetes-sigs/kubespray),
сформировать inventory-директорию, содержащую сам `inventory.ini` с данными о виртуальных машинах и `group_vars`.

После данного шага достаточно запустить ansible-playbook `cluster.yml` с переданным inventory:

```shell
ansible-playbook -i ansible/kubespray/inventory.ini vendor/kubespray/cluster.yml
```

Когда установка кластера закончится необходимо с control-node взять файл `/etc/kubernetes/admin.conf`,
положить его локально по пути `~/.kube/conf` и изменить ip-адрес кластера на ip-адрес самой control-node.
Этого будет достаточно, чтобы подключится к кластеру через утилиту `kubectl`.

```shell
kubectl get pods --all-namespaces
```

```text
NAMESPACE     NAME                                       READY   STATUS    RESTARTS      AGE
kube-system   calico-kube-controllers-7f679c5d6f-kfmkz   1/1     Running   0             49m
kube-system   calico-node-8v2d9                          1/1     Running   0             50m
kube-system   calico-node-rrbcv                          1/1     Running   0             50m
kube-system   calico-node-w67gl                          1/1     Running   0             50m
kube-system   coredns-5867d9544c-7n4qz                   1/1     Running   0             47m
kube-system   coredns-5867d9544c-rfbxs                   1/1     Running   0             47m
kube-system   dns-autoscaler-59b8867c86-2rqdd            1/1     Running   0             47m
<...>
```

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