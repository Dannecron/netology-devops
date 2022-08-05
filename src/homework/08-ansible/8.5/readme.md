Выполнение [домашнего задания](https://github.com/netology-code/mnt-homeworks/blob/MNT-13/08-ansible-05-testing/README.md)
по теме "8.5. Тестирование Roles".

## Q/A

### Задание 1

> Подготовка к выполнению
> 1. Установите `molecule`: `pip3 install "molecule==3.5.2"`
> 2. Выполните `docker pull aragast/netology:latest` - это образ с `podman`, `tox` и несколькими пайтонами (3.7 и 3.9) внутри


Установка `molecule`:

```shell
pip3 install "molecule==3.5.2" --user
```

```shell
molecule --version
```

```text
molecule 3.5.2 using python 3.8
    ansible:2.13.1
    delegated:3.5.2 from molecule
```

Получение образа:

```shell
docker pull aragast/netology:latest
```

```shell
docker run --rm aragast/netology:latest podman --version
```

```text
podman version 4.0.2
```

### Задание 2

> Основная часть
> Наша основная цель - настроить тестирование наших ролей.
> Задача: сделать сценарии тестирования для vector.
> Ожидаемый результат: все сценарии успешно проходят тестирование ролей.

> #### Molecule
> 1. Запустите `molecule test -s centos7` внутри корневой директории `clickhouse-role`, посмотрите на вывод команды.

```shell
molecule test -s centos_7
```

Полный вывод команды: [molecule_output_clickhouse.txt](./molecule_output_clickhouse.txt).

> 2. Перейдите в каталог с ролью `vector-role` и создайте сценарий тестирования по умолчанию при помощи `molecule init scenario --driver-name docker`

```shell
molecule init scenario --driver-name docker
```

```text
INFO     Initializing new scenario default...
INFO     Initialized scenario in /home/dannc/code/learning/netology-devops-ansible-vector/molecule/default successfully.
```

> 3. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.

Роль была расширена путём добавления поддержки debian-based дистрибутивов (пакетный менеджер `apt`).
Дополнительно, в сценарий по умолчанию добавлена проверка на образе `debian:bullsyeye`.

> 4. Добавьте несколько assert'ов в verify.yml файл для проверки работоспособности vector-role (проверка, что конфиг валидный, проверка успешности запуска, etc).
> Запустите тестирование роли повторно и проверьте, что оно прошло успешно.

В `verify.yml` была добавлена проверка на успешный запуск сервиса `vector`:
```yaml
- name: ensure vector service started
  ansible.builtin.service:
    name: vector
    state: started
```

> 5. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

Так как в данном случае было расширение функционала без потери обратной совместимости, то по семантическому версионированию 
новая версия будет иметь тэг `1.1.0`.

Новая версия доступна по ссылке: [Dannecron/netology-devops-ansible-vector:1.1.0](https://github.com/Dannecron/netology-devops-ansible-vector/releases/tag/1.1.0)

> #### Tox
> 1. Добавьте в директорию с vector-role файлы из [директории](https://github.com/netology-code/mnt-homeworks/blob/MNT-13/08-ansible-05-testing/example)
> 2. Запустите `docker run --privileged=True -v <path_to_repo>:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash`, где path_to_repo - путь до корня репозитория с vector-role на вашей файловой системе.
> 3. Внутри контейнера выполните команду `tox`, посмотрите на вывод.

// todo

> 4. Создайте облегчённый сценарий для `molecule` с драйвером `molecule_podman`. Проверьте его на исполнимость.

// todo

> 5. Пропишите правильную команду в `tox.ini` для того чтобы запускался облегчённый сценарий.

// todo

> 6. Запустите команду `tox`. Убедитесь, что всё отработало успешно.

// todo

> 7. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

// todo
