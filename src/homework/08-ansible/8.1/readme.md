Выполнение [домашнего задания](https://github.com/netology-code/mnt-homeworks/blob/MNT-13/08-ansible-01-base/README.md)
по теме "8.1. Введение в Ansible".

## Q/A

### Задание 1

> Подготовка к выполнению
> 1. Установите ansible версии 2.10 или выше
> 2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
> 3. Скачайте playbook из репозитория с домашним заданием и перенесите его в свой репозиторий.

Установку `ansible` производил через `pip`.

```shell
ansible --version
```

```text
ansible [core 2.13.1]
```

Репозиторий расположен по [ссылке](https://github.com/Dannecron/netology-devops). 

Playbook расположен в директории [playbook](./playbook).

### Задание 2

> Основная часть.
> 1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.

```shell
ansible-playbook -i inventory/test.yml site.yml
```

```text
PLAY [Print os facts] ******************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************
ok: [localhost]

TASK [Print OS] ************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **********************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP *****************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Переменная `some_fact` в данном случае равна `12`.

> 2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.

Переменная задаётся в файле [group_vars/all/example.yml](./playbook/group_vars/all/example.yml). После изменения файл будет выглядеть следующим образом:

```yaml
---
some_fact: "all default fact"
```

> 3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.

Заменил образ `ubuntu` на образ `debian` ([официальный образ `python`](https://hub.docker.com/_/python), основанный на debian)
и, соответственно, изменил название контейнера в [inventory/prod.yml](./playbook/inventory/prod.yml).

Запуск контейнеров производится командой:

```shell
docker run --rm -d --name=centos7 centos:7  tail -f /dev/null \
  && docker run --rm -d --name=debian python:slim tail -f /dev/null
```

> 4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.

```shell
ansible-playbook -i inventory/prod.yml site.yml
```

```text
PLAY [Print os facts] ********************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************
[WARNING]: Distribution debian 11 on host debian should use /usr/bin/python3, but is using /usr/local/bin/python3.10, since the discovered platform python interpreter was
not present. See https://docs.ansible.com/ansible-core/2.13/reference_appendices/interpreter_discovery.html for more information.
ok: [debian]
ok: [centos7]

TASK [Print OS] **************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [debian] => {
    "msg": "Debian"
}

TASK [Print fact] ************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [debian] => {
    "msg": "deb"
}

PLAY RECAP *******************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
debian                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Таким образом, переменная `some_fact` имеет следующие значения:
* для `debian` - `deb`
* для `centos7` - `el`

> 5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.

В данном случае необходимо отредактировать файлы [group_vars/deb/example.yml](./playbook/group_vars/deb/example.yml)
и [group_vars/el/example.yml](./playbook/group_vars/el/example.yml).

> 6. Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.


```shell
ansible-playbook -i inventory/prod.yml site.yml
```

```text
PLAY [Print os facts] ********************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************
[WARNING]: Distribution debian 11 on host debian should use /usr/bin/python3, but is using /usr/local/bin/python3.10, since the discovered platform python interpreter was
not present. See https://docs.ansible.com/ansible-core/2.13/reference_appendices/interpreter_discovery.html for more information.
ok: [debian]
ok: [centos7]

TASK [Print OS] **************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [debian] => {
    "msg": "Debian"
}

TASK [Print fact] ************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [debian] => {
    "msg": "deb default fact"
}

PLAY RECAP *******************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
debian                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```


> 7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.

```shell
ansible-vault encrypt group_vars/deb/example.yml
```

```shell
ansible-vault encrypt group_vars/el/example.yml
```

> 8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.

```shell
ansible-playbook --ask-vault-pass -i inventory/prod.yml site.yml
```

```text
PLAY [Print os facts] ******************************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************************
[WARNING]: Distribution debian 11 on host debian should use /usr/bin/python3, but is using /usr/local/bin/python3.10, since the discovered platform python interpreter was not present.
See https://docs.ansible.com/ansible-core/2.13/reference_appendices/interpreter_discovery.html for more information.
ok: [debian]
ok: [centos7]

TASK [Print OS] ************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [debian] => {
    "msg": "Debian"
}

TASK [Print fact] **********************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [debian] => {
    "msg": "deb default fact"
}

PLAY RECAP *****************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
debian                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

> 9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.

Для выполнения команд на `control node` (машине, с которой производится запуск `playbook`), можно использовать модуль [`local_action`](https://docs.ansible.com/ansible/latest/user_guide/playbooks_delegation.html).
К сожалению, в `ansible-doc` не смог найти встроенных модулей, а документации к `local_action` в данной утилите нет.

```shell
ansible-doc local_action
```

```text
[WARNING]: module local_action not found in: ~/.ansible/plugins/modules:/usr/share/ansible/plugins/modules:~/.local/lib/python3.8/site-packages/ansible/modules
```

> 10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.

Новая группа хостов будет выглядеть следующим образом:

```yaml
local:
  hosts:
    localhost:
      ansible_connection: local
```

> 11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

```shell
ansible-playbook --ask-vault-pass -i inventory/prod.yml site.yml
```

```text
PLAY [Print os facts] ******************************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************************
ok: [localhost]
[WARNING]: Distribution debian 11 on host debian should use /usr/bin/python3, but is using /usr/local/bin/python3.10, since the discovered platform python interpreter was not present.
See https://docs.ansible.com/ansible-core/2.13/reference_appendices/interpreter_discovery.html for more information.
ok: [debian]
ok: [centos7]

TASK [Print OS] ************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [debian] => {
    "msg": "Debian"
}
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **********************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [debian] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP *****************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
debian                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

> 12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

//todo
