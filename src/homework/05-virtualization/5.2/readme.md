Выполнение [домашнего задания](https://github.com/netology-code/virt-homeworks/blob/virt-11/05-virt-02-iaac/README.md) 
по теме "5.2. Применение принципов IaaC в работе с виртуальными машинами".

## Q/A

### Задача 1
> Опишите своими словами основные преимущества применения на практике IaaC паттернов.

Основные преимущества применения IaaC паттернов:
1. Хранение всей конфигурации инфраструктуры под системой контроля версий. Это даёт множество приемуществ:
   1. Версионирование конфигурации, что позволяет сравнивать версии, видеть развитие, отлавливать ошибки на код-ревью.
   2. Хранение конфигурации в централизованном хранилище (например, `github`/`gitlab`/`bitbucket`)
   3. Возможность коллаборации инженеров в работе над конфигурацией. То есть, возможность одновременно вносить доработки
     в одну часть инфраструктуры одним человеком, и добавлять новые сервисы другим.
2. Возможность "прочитать" конфигурацию, чтобы понять, как она работает, а не выяснять это опытным путём.
3. Возможность тестирования конфигурации.
4. Возможность автоматизировать частично или полностью применение конфигурации к инфраструктуре.

> Какой из принципов IaaC является основополагающим?

Основополагающий принцип IaaC - это идемпотентность. То есть, применяя готовую конфигурацию к инфраструктуре
(например, развёртывание виртуальных машин) инженер будет получать один и тот же ожидаемый результат, который не будет меняться,
сколько бы попыток не было.

### Задача 2

> Чем Ansible выгодно отличается от других систем управление конфигурациями?

Самое главное преимущество `ansible` - это необходимость установки утилиты только на машине,
откуда необходимо запустить применение конфигурации. То есть, на физических/виртуальных машинах, где будут происходить действия
по настройке никаких дополнительных утилит устанавливать не нужно.

> Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

Принцип `push` более надёжный, так как для данного метода не нужно держать активным некий сервис,
который будет принимать и обрабатывать запросы клиентов на обновление конфигурации.

При этом построение развёртывания конфигурации по принципу `push` проще, чем построение гибридного подхода,
что повышает надёжность на первых этапах построения инфраструктуры.

### Задача 3

> Установить на личный компьютер:
> * VirtualBox 
> * Vagrant 
> * Ansible 
> 
> Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.

```shell
virtualbox --help
Oracle VM VirtualBox VM Selector v6.1.32
(C) 2005-2022 Oracle Corporation
All rights reserved.
```

```shell
vagrant --version
Vagrant 2.2.19
```

```shell
ansible --version
ansible [core 2.12.4]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['~/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = ~/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Mar 15 2022, 12:22:08) [GCC 9.4.0]
  jinja version = 2.10.1
  libyaml = True
```

### Задача 4 (*)

> Воспроизвести практическую часть лекции самостоятельно.
> Создать виртуальную машину.

Для создания виртуальной машины используется уже готовый [`Vagrantfile`](/src/vagrant/Vagrantfile),
в который дополнительно добавлены команды необходимые для установки `docker`:

```
  config.vm.provision "shell", inline: <<-SHELL
    apt update
    apt install -y ca-certificates \
        curl \
        gnupg \
        lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io
    usermod -aG docker vagrant
  SHELL
```
 
> Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды `docker ps`

```shell
vagrant ssh
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-91-generic x86_64)
<...>

vagrant@vagrant:~$ docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

vagrant@vagrant:~$ docker run --rm hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
2db29710123e: Pull complete 
Digest: sha256:10d7d58d5ebd2a652f4d93fdd86da8f265f5318c6a73cc5b6a9798ff6d2b2e67
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
<...>
``` 

