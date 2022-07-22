Выполнение [домашнего задания](https://github.com/netology-code/mnt-homeworks/blob/MNT-13/08-ansible-02-playbook/README.md)
по теме "8.2. Работа с Playbook".

## Q/A

### Задание 1

> Подготовка к выполнению
> 1. (Необязательно) Изучите, что такое [clickhouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [vector](https://www.youtube.com/watch?v=CgEhyffisLY)
> 2. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
> 3. Скачайте [playbook](https://github.com/netology-code/mnt-homeworks/tree/MNT-13/08-ansible-02-playbook/playbook) из репозитория с домашним заданием и перенесите его в свой репозиторий.
> 4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

Новый playbook расположен в [одноимённой директории](./playbook).
Хосты прописываются в файле [inventory/prod.yml](./playbook/inventory/prod.yml), который необходимо создать из [playbook.yml.example](./playbook/inventory/prod.yml.example).

Дополнительно перенёс `handler` с именем `Start clickhouse service` в отдельный `task`, так как по какой-то причине `handler`
иногда не отрабатывал из-за таймаута. При этом следующий `task` не отрабатывал из-за того, что сервис `clickhouse-server` не был запущен.

### Задание 2

> Основная часть
> 1. Приготовьте свой собственный inventory файл prod.yml

Файл [inventory/prod.yml](./playbook/inventory/prod.yml) будет выглядеть в точности как [playbook.yml.example](./playbook/inventory/prod.yml.example),
только с прописанным ip-адресом.

> 2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev/).
> 3. При создании tasks рекомендуется использовать модули: `get_url`, `template`, `unarchive`, `file`.
> 4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить `vector`

На официальном сайте есть несколько путей установить `vector`:
- Через [установщик](https://vector.dev/docs/setup/installation/manual/vector-installer/), но в таком случае не понятно,
  как указать версию.
- Через [пакетный менеджер yum](https://vector.dev/docs/setup/installation/package-managers/yum/).  
  Этот вариант требует добавление нового стороннего репозитория в систему.
- Путём [скачивания скомпилированного исполняемого файла](https://vector.dev/docs/setup/installation/manual/from-archives/).

Был выбран последний вариант как наиболее надёжный. В таком случае будут определены следующие шаги выполнения установки:
- установка менеджера архивов `tar` на машине
- скачивание архива с официального сайта
- распаковка архива
- копирование исполняемого файла в одну из директорий из списка `PATH` (например, `/usr/local/bin`)

С учётом данных шагов весь play по установке будет выглядеть следующим образом:

```yaml
- name: Install vector
  hosts: vector
  tasks:
    - name: Install archive manager
      become: true
      ansible.builtin.yum:
        name:
          - tar
    - name: Get vector distrib
      ansible.builtin.get_url:
        url: "https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-x86_64-unknown-linux-musl.tar.gz"
        dest: "./vector-{{ vector_version }}-x86_64-unknown-linux-musl.tar.gz"
    - name: Unpack vector distrib
      ansible.builtin.unarchive:
        src: "./vector-{{ vector_version }}-x86_64-unknown-linux-musl.tar.gz"
        dest: "./"
        remote_src: true
    - name: Install vector
      become: true
      ansible.builtin.copy:
        src: "vector-x86_64-unknown-linux-musl/bin/vector"
        dest: "/usr/local/bin/"
        remote_src: true
        mode: 755
    - name: Check vector version
      ansible.builtin.shell:
        cmd: vector --version
      register: result
      changed_when:
        - 'vector_version not in result.stdout'
      tags:
        - vector_check_version
  tags:
    - vector
```

При этом, нужно добавить новую группу хостов в [inventory/prod.yml](./playbook/inventory/prod.yml).

```yaml
vector:
  hosts:
    vector-01:
      ansible_host: <IP_here>
```

> 5. Запустите ansible-lint site.yml и исправьте ошибки, если они есть.


```shell
ansible-playbook -i inventory/prod.yml site.yml --tags=vector
```

```text
PLAY [Install Clickhouse] **************************************************************************************************
PLAY [Install vector] ******************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************
ok: [vector-01]

TASK [Install archive manager] *********************************************************************************************
ok: [vector-01]

TASK [Get vector distrib] **************************************************************************************************
changed: [vector-01]

TASK [Unpack vector distrib] ***********************************************************************************************
changed: [vector-01]

TASK [Install vector] ******************************************************************************************************
changed: [vector-01]

TASK [Check vector version] ************************************************************************************************
changed: [vector-01]

PLAY RECAP *****************************************************************************************************************
vector-01                  : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

> 6. Попробуйте запустить playbook на этом окружении с флагом --check.

```shell
 ansible-playbook -i inventory/prod.yml site.yml --tags=vector --check
```

```text
PLAY [Install Clickhouse] **************************************************************************************************

PLAY [Install vector] ******************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************
ok: [vector-01]

TASK [Install archive manager] *********************************************************************************************
ok: [vector-01]

TASK [Get vector distrib] **************************************************************************************************
ok: [vector-01]

TASK [Unpack vector distrib] ***********************************************************************************************
skipping: [vector-01]

TASK [Install vector] ******************************************************************************************************
ok: [vector-01]

TASK [Check vector version] ************************************************************************************************
skipping: [vector-01]

PLAY RECAP *****************************************************************************************************************
vector-01                  : ok=4    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
```

> 7. Запустите playbook на prod.yml окружении с флагом --diff. Убедитесь, что изменения на системе произведены.

```shell
ansible-playbook -i inventory/prod.yml site.yml --tags=vector --diff
```

```text
PLAY [Install Clickhouse] **************************************************************************************************

PLAY [Install vector] ******************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************
ok: [vector-01]

TASK [Install archive manager] *********************************************************************************************
ok: [vector-01]

TASK [Get vector distrib] **************************************************************************************************
ok: [vector-01]

TASK [Unpack vector distrib] ***********************************************************************************************
ok: [vector-01]

TASK [Install vector] ******************************************************************************************************
ok: [vector-01]

TASK [Check vector version] ************************************************************************************************
ok: [vector-01]

PLAY RECAP *****************************************************************************************************************
vector-01                  : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

> 8. Повторно запустите playbook с флагом --diff и убедитесь, что playbook идемпотентен

```shell
ansible-playbook -i inventory/prod.yml site.yml --tags=vector --diff
```

```text
PLAY [Install Clickhouse] **************************************************************************************************

PLAY [Install vector] ******************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************
ok: [vector-01]

TASK [Install archive manager] *********************************************************************************************
ok: [vector-01]

TASK [Get vector distrib] **************************************************************************************************
ok: [vector-01]

TASK [Unpack vector distrib] ***********************************************************************************************
ok: [vector-01]

TASK [Install vector] ******************************************************************************************************
ok: [vector-01]

TASK [Check vector version] ************************************************************************************************
ok: [vector-01]

PLAY RECAP *****************************************************************************************************************
vector-01                  : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

> 9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

Написан [playbook/readme.md](./playbook/readme.md).
