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

```shell
tox
```

```text
py37-ansible210 create: /opt/vector-role/.tox/py37-ansible210
py37-ansible210 installdeps: -rtox-requirements.txt, ansible<3.0
py37-ansible210 installed: ansible==2.10.7,ansible-base==2.10.17,ansible-compat==1.0.0,ansible-lint==5.1.3,arrow==1.2.2,bcrypt==3.2.2,binaryornot==0.4.4,bracex==2.3.post1,cached-property==1.5.2,Cerberus==1.3.2,certifi==2022.6.15,cffi==1.15.1,chardet==5.0.0,charset-normalizer==2.1.0,click==8.1.3,click-help-colors==0.9.1,commonmark==0.9.1,cookiecutter==2.1.1,cryptography==37.0.4,distro==1.7.0,enrich==1.2.7,idna==3.3,importlib-metadata==4.12.0,Jinja2==3.1.2,jinja2-time==0.2.0,jmespath==1.0.1,lxml==4.9.1,MarkupSafe==2.1.1,molecule==3.4.0,molecule-podman==1.0.1,packaging==21.3,paramiko==2.11.0,pathspec==0.9.0,pluggy==0.13.1,pycparser==2.21,Pygments==2.12.0,PyNaCl==1.5.0,pyparsing==3.0.9,pytho
n-dateutil==2.8.2,python-slugify==6.1.2,PyYAML==5.4.1,requests==2.28.1,rich==12.5.1,ruamel.yaml==0.17.21,ruamel.yaml.clib==0.2.6,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.5,tenacity==8.0.1,text-unidecode==1.3,typing_extensions==4.3.0,urllib3==1.26.11,wcmatch==8.4,yamllint==1.26.3,zipp==3.8.1
py37-ansible210 run-test-pre: PYTHONHASHSEED='237061875'
py37-ansible210 run-test: commands[0] | molecule test -s compatibility --destroy always
CRITICAL 'molecule/compatibility/molecule.yml' glob failed.  Exiting.
ERROR: InvocationError for command /opt/vector-role/.tox/py37-ansible210/bin/molecule test -s compatibility --destroy always (exited with code 1)
py37-ansible30 create: /opt/vector-role/.tox/py37-ansible30
py37-ansible30 installdeps: -rtox-requirements.txt, ansible<3.1
py37-ansible30 installed: ansible==3.0.0,ansible-base==2.10.17,ansible-compat==1.0.0,ansible-lint==5.1.3,arrow==1.2.2,bcrypt==3.2.2,binaryornot==0.4.4,bracex==2.3.post1,cache
d-property==1.5.2,Cerberus==1.3.2,certifi==2022.6.15,cffi==1.15.1,chardet==5.0.0,charset-normalizer==2.1.0,click==8.1.3,click-help-colors==0.9.1,commonmark==0.9.1,cookiecutte
r==2.1.1,cryptography==37.0.4,distro==1.7.0,enrich==1.2.7,idna==3.3,importlib-metadata==4.12.0,Jinja2==3.1.2,jinja2-time==0.2.0,jmespath==1.0.1,lxml==4.9.1,MarkupSafe==2.1.1,
molecule==3.4.0,molecule-podman==1.0.1,packaging==21.3,paramiko==2.11.0,pathspec==0.9.0,pluggy==0.13.1,pycparser==2.21,Pygments==2.12.0,PyNaCl==1.5.0,pyparsing==3.0.9,python-
dateutil==2.8.2,python-slugify==6.1.2,PyYAML==5.4.1,requests==2.28.1,rich==12.5.1,ruamel.yaml==0.17.21,ruamel.yaml.clib==0.2.6,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.5,tenacity==8.0.1,text-unidecode==1.3,typing_extensions==4.3.0,urllib3==1.26.11,wcmatch==8.4,yamllint==1.26.3,zipp==3.8.1
py37-ansible30 run-test-pre: PYTHONHASHSEED='237061875'
py37-ansible30 run-test: commands[0] | molecule test -s compatibility --destroy always
CRITICAL 'molecule/compatibility/molecule.yml' glob failed.  Exiting.
ERROR: InvocationError for command /opt/vector-role/.tox/py37-ansible30/bin/molecule test -s compatibility --destroy always (exited with code 1)
py39-ansible210 create: /opt/vector-role/.tox/py39-ansible210
py39-ansible210 installdeps: -rtox-requirements.txt, ansible<3.0
py39-ansible210 installed: ansible==2.10.7,ansible-base==2.10.17,ansible-compat==2.2.0,ansible-lint==5.1.3,arrow==1.2.2,attrs==22.1.0,bcrypt==3.2.2,binaryornot==0.4.4,bracex=
=2.3.post1,Cerberus==1.3.2,certifi==2022.6.15,cffi==1.15.1,chardet==5.0.0,charset-normalizer==2.1.0,click==8.1.3,click-help-colors==0.9.1,commonmark==0.9.1,cookiecutter==2.1.
1,cryptography==37.0.4,distro==1.7.0,enrich==1.2.7,idna==3.3,Jinja2==3.1.2,jinja2-time==0.2.0,jmespath==1.0.1,jsonschema==4.9.1,lxml==4.9.1,MarkupSafe==2.1.1,molecule==3.4.0,
molecule-podman==1.0.1,packaging==21.3,paramiko==2.11.0,pathspec==0.9.0,pluggy==0.13.1,pycparser==2.21,Pygments==2.12.0,PyNaCl==1.5.0,pyparsing==3.0.9,pyrsistent==0.18.1,pyth
on-dateutil==2.8.2,python-slugify==6.1.2,PyYAML==5.4.1,requests==2.28.1,rich==12.5.1,ruamel.yaml==0.17.21,ruamel.yaml.clib==0.2.6,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.5,tenacity==8.0.1,text-unidecode==1.3,urllib3==1.26.11,wcmatch==8.4,yamllint==1.26.3
py39-ansible210 run-test-pre: PYTHONHASHSEED='237061875'
py39-ansible210 run-test: commands[0] | molecule test -s compatibility --destroy always
CRITICAL 'molecule/compatibility/molecule.yml' glob failed.  Exiting.
ERROR: InvocationError for command /opt/vector-role/.tox/py39-ansible210/bin/molecule test -s compatibility --destroy always (exited with code 1)
py39-ansible30 create: /opt/vector-role/.tox/py39-ansible30
py39-ansible30 installdeps: -rtox-requirements.txt, ansible<3.1
py39-ansible30 installed: ansible==3.0.0,ansible-base==2.10.17,ansible-compat==2.2.0,ansible-lint==5.1.3,arrow==1.2.2,attrs==22.1.0,bcrypt==3.2.2,binaryornot==0.4.4,bracex==2
.3.post1,Cerberus==1.3.2,certifi==2022.6.15,cffi==1.15.1,chardet==5.0.0,charset-normalizer==2.1.0,click==8.1.3,click-help-colors==0.9.1,commonmark==0.9.1,cookiecutter==2.1.1,
cryptography==37.0.4,distro==1.7.0,enrich==1.2.7,idna==3.3,Jinja2==3.1.2,jinja2-time==0.2.0,jmespath==1.0.1,jsonschema==4.9.1,lxml==4.9.1,MarkupSafe==2.1.1,molecule==3.4.0,mo
lecule-podman==1.0.1,packaging==21.3,paramiko==2.11.0,pathspec==0.9.0,pluggy==0.13.1,pycparser==2.21,Pygments==2.12.0,PyNaCl==1.5.0,pyparsing==3.0.9,pyrsistent==0.18.1,python
-dateutil==2.8.2,python-slugify==6.1.2,PyYAML==5.4.1,requests==2.28.1,rich==12.5.1,ruamel.yaml==0.17.21,ruamel.yaml.clib==0.2.6,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.5,tenacity==8.0.1,text-unidecode==1.3,urllib3==1.26.11,wcmatch==8.4,yamllint==1.26.3
py39-ansible30 run-test-pre: PYTHONHASHSEED='237061875'
py39-ansible30 run-test: commands[0] | molecule test -s compatibility --destroy always
CRITICAL 'molecule/compatibility/molecule.yml' glob failed.  Exiting.
ERROR: InvocationError for command /opt/vector-role/.tox/py39-ansible30/bin/molecule test -s compatibility --destroy always (exited with code 1)
__________________________________________________________________________________ summary ___________________________________________________________________________________
ERROR:   py37-ansible210: commands failed
ERROR:   py37-ansible30: commands failed
ERROR:   py39-ansible210: commands failed
ERROR:   py39-ansible30: commands failed
```

> 4. Создайте облегчённый сценарий для `molecule` с драйвером `molecule_podman`. Проверьте его на исполнимость.

Новый сценарий называется `podman` и расположен в репозитории с ролью.
Для проверки его на исполнимость нужно выполнить следующие шаги:
1. Добавить в переменную окружения `PATH` внутри контейнера путь до одной из версий `python` и `ansible` из директории `.tox`

```shell
export PATH="$PATH:/opt/vector-role/.tox/py37-ansible30/bin"
```

2. Проверить успешность добавления (все утилиты будут доступны без указания конкретного пути)

```shell
ansible --version
```

```text
ansible 2.10.17
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /opt/vector-role/.tox/py37-ansible30/lib/python3.7/site-packages/ansible
  executable location = /opt/vector-role/.tox/py37-ansible30/bin/ansible
  python version = 3.7.10 (default, Jun 13 2022, 19:37:24) [GCC 8.5.0 20210514 (Red Hat 8.5.0-10)]
```

```shell
molecule --version
```

```text
molecule 3.4.0 using python 3.7 
    ansible:2.10.17
    delegated:3.4.0 from molecule
    podman:1.0.1 from molecule_podman requiring collections: containers.podman>=1.7.0 ansible.posix>=1.3.0
```

3. Запустить новый сценарий.

```shell
molecule test -s podman
```

```text
// todo
```

> 5. Пропишите правильную команду в `tox.ini` для того чтобы запускался облегчённый сценарий.

```ini
commands =
    {posargs:molecule test -s podman}
```

> 6. Запустите команду `tox`. Убедитесь, что всё отработало успешно.

```shell
tox
```

```text
// todo
```

> 7. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

// todo
