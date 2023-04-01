## Дипломная работа

Выполнение дипломной работы курса netology DevOps инженер. Оригинал задания доступен по [ссылке](https://github.com/netology-code/devops-diplom-yandexcloud/blob/main/README.md).

Весь код, выполненный по ходу выполнения работы находится в репозиториях на github:
* terraform/ansible/helm: [Dannecron/netology-devops-gw-infra](https://github.com/Dannecron/netology-devops-gw-infra)
* приложение: [Dannecron/parcel-example-neko](https://github.com/Dannecron/parcel-example-neko)

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

Для данного задания будет использован [репозиторий тестового приложения](https://github.com/Dannecron/parcel-example-neko)
в котором расположено небольшое тестовое приложение на JS. Данное приложение запаковывается в образ с nginx.
Dockerfile расположен внутри репозитория ([file](https://github.com/Dannecron/parcel-example-neko/blob/main/Dockerfile))

Docker-образ доступен на [Docker Hub](https://hub.docker.com/r/dannecron/parcel-example-neko).

---

### Подготовка системы мониторинга и деплой приложения

[Задание](./tasks.md#подготовка-системы-мониторинга-и-деплой-приложения).

Перед деплоем необходимо было активировать nginx-ingress-controller в конфигурации kubespray.
Для этого в файле [ansible/kubespray/group_vars/k8s_cluster/addons.yml](https://github.com/Dannecron/netology-devops-gw-infra/blob/main/ansible/kubespray/group_vars/k8s_cluster/addons.yml) изменено значение 
по ключам `ingress_nginx_enabled` и `ingress_nginx_host_network` на `true`.

Для деплоя всех необходимых сервисов было создано 2 helm-чарта и использован готовый helm-чарт:
* чарт [k8s/helm/atlantis](https://github.com/Dannecron/netology-devops-gw-infra/tree/main/k8s/helm/atlantis) для упрощённого деплоя `atlantis`
* чарт [k8s/helm/simple-app](https://github.com/Dannecron/netology-devops-gw-infra/tree/main/k8s/helm/simple-app) для
* готовый чарт [kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)
  и конфигурация для него [k8s/helm/kube-prometheus-stack/values.yml](https://github.com/Dannecron/netology-devops-gw-infra/blob/main/k8s/helm/kube-prometheus-stack/values.yml)

Применение изменений производится командами `helm`: 
* `helm install` - первый деплой чарта
* `helm upgrade` - повторный деплой чарта для применения изменений
* `helm upgrade -i` - установка или обновление чарта

Конкретные команды, которые были выполнены:

```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -f k8s/helm/kube-prometheus-stack/values.yml
helm install simple-app k8s/helm/simple-app
helm install --set "config.github.user=<access_token>" --set "config.github.token=<token_secret>" --set "config.github.secret=<webhook_secret>" atlantis k8s/helm/atlantis
```

где `<access_token>`, `<token_secret>` - это данные персонального access-токена, созданного на github,
а `<webhook_secret>` - строка, которая должна совпадать в конфигурации webhook и atlantis.

После выполнения сервисы стали доступны по следующим доменам:
* `http://grafana-gw.my.to` - grafana (логин `admin`, пароль `prom-operator`)
* `http://app-gw.my.to` - приложение
* `http://atlantis-gw.my.to/` - atlantis

_UPD_ atlantis был подключён к репозиторию, но не получается корректно настроить backend для terraform.
Особенно вызывает проблемы необходимость каждый день выпускать новый токен для сервисного аккаунта yandex.cloud.

---

### Установка и настройка CI/CD

[Задание](./tasks.md#установка-и-настройка-CI/CD).

В качестве сервиса автоматизации сборки и развёртывания приложения был выбран [jenkins](https://www.jenkins.io/).
Для его деплоя создан helm-чарт [k8s/helm/jenkins](https://github.com/Dannecron/netology-devops-gw-infra/tree/main/k8s/helm/jenkins),
деплой которого производится стандартно:

```shell
helm install --set "docker.dockerHubUser=<dockerHubUser>" --set "docker.dockerHubPassword=<dockerHubPassword>" jenkins k8s/helm/jenkins
```

где `<dockerHubUser>` и `<dockerHubPassword>` - данные авторизации в [hub.docker.com](https://hub.docker.com)
для возможности пушить образы в регистри.

После установки jenkins будет доступен по ip-адресу любой рабочей node кластера по пути `/jenkins` (например ` http://84.201.172.95/jenkins`).
Далее необходима первоначальная настройка сервиса в которую входят:
* авторизация в качестве начального администратора. Ключ доступа можно посмотреть в логах pod, например, командой:
    
    ```shell
    kubectl --namespace ci-cd logs jenkins-production-main-0
    ``` 
* установка первоначальных плагинов (можно выбрать рекомендованный вариант).
* создание дополнительного пользователя (можно пропустить).
* изменение конфигурации безопасности `Host Key Verification Strategy` на `Accept first connection`
* установка дополнительных плагинов:
  * [Kubernetes](https://plugins.jenkins.io/kubernetes/) для возможности запускать jenkins-воркеры внутри k8s-кластера
  * [Generic Webhook Trigger](https://plugins.jenkins.io/generic-webhook-trigger/) для возможности более гибко настраивать
    поведение скриптов jenkins на github-webhooks.
* выставить значение 0 в настройке `Количество процессов-исполнителей` для мастер-ноды.
* в `Configure Clouds` добавить новую конфигурацию kubernetes. Адрес кластера и сертификат можно взять из локальной конфигурации `kubectl`.

После данных действий останется создать два проекта с типом `pipeline`:
* для сборки образов при каждом изменении кода в ветках. Скрипт для этого проекта находится в файле [jenkins/ref.jenkinsfile](https://github.com/Dannecron/netology-devops-gw-infra/blob/main/jenkins/ref.jenkinsfile)
* для сборки образов и деплое изменений при создании нового git-тэга. Скрипт для этого проекта находится в файле [jenkins/tag.jenkinsfile](https://github.com/Dannecron/netology-devops-gw-infra/blob/main/jenkins/tag.jenkinsfile)

Плагин `Generic Webhook Trigger`, который используется внутри данных скриптов, требует, чтобы сборка каждого проекта была запущена
хотя бы раз перед фактическим использованием. Это необходимо для применения конфигурации переменных для проекта.

Последним шагом будет настройка двух github-webhook в репозитории приложения [Dannecron/parcel-example-neko](https://github.com/Dannecron/parcel-example-neko).
Webhook для первого приложения должен инициироваться при каждом push в репозиторий (`Just the push event.`).
Webhook для второго приложения должен инициироваться только при создании тэга (`Branch or tag creation`, создание веток будет отфильтровано). 

По такой логике были созданы следующие теги в [регистри](https://hub.docker.com/r/dannecron/parcel-example-neko/tags)
* `feature-1` - при создании новой git-ветки в репозитории.
* `0.1.0` - при создании нового тега. При этом в кластер была задеплоена соответствующая версия приложения. Это можно проверить, выполнив команды

    ```shell
    helm list --selector "name=simple-app"
    kubectl describe pod --show-events=false simple-app-production-application-7c777968c6-cndh2 | grep Image
    ```
    
    ```text
    NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART            APP VERSION
    simple-app      default         3               2023-04-01 04:48:20.999406345 +0000 UTC deployed        simple-app-0.1.0 latest

    Image:          dannecron/parcel-example-neko:0.1.0
    ```

---

### Данные, необходимые для сдачи задания

1. Репозиторий с конфигурационными файлами Terraform: [Dannecron/netology-devops-gw-infra](https://github.com/Dannecron/netology-devops-gw-infra) директория `terraform`;
2. Пример pull request с комментариями созданными atlantis'ом: [github](https://github.com/Dannecron/netology-devops-gw-infra/pull/2);
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible:
    [Dannecron/netology-devops-gw-infra](https://github.com/Dannecron/netology-devops-gw-infra) директория `ansible /kubespray`;
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image:
    * репозиторий тестового приложения: [Dannecron/parcel-example-neko](https://github.com/Dannecron/parcel-example-neko);
    * docker image: [dannecron/parcel-example-neko](https://hub.docker.com/r/dannecron/parcel-example-neko);
5. Репозиторий с конфигурацией Kubernetes кластера: [Dannecron/netology-devops-gw-infra](https://github.com/Dannecron/netology-devops-gw-infra) директория `k8s`;
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа:
    * тестовое приложение: `http://app-gw.my.to`
    * web-интерфейс grafana: `http://grafana-gw.my.to` (логин `admin`, пароль `prom-operator`)

### Допущения

Небольшой список допущений, которые были сделаны во время выполнения работы:
* Все ноды имеют внешний ip-адрес. В реальном проекте стоило сделать `Bastion host` для доступа по ssh до всех остальных нод,
  а так же перенаправления трафика к кластеру.
* Создано несколько ansible-playbook под разные задачи. Возможно, стоило объединить всё в один playbook с подключением разных ролей.
* Helm-чарт для деплоя приложения никуда не опубликован, что усложняет работу с ним.
  Таким образом, в дальнейшем стоит настроить хотя бы публикацию версии (архива) в качестве артефактов в релизах github.
