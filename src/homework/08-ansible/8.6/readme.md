Выполнение [домашнего задания](https://github.com/netology-code/mnt-homeworks/blob/MNT-13/08-ansible-06-module/README.md)
по теме "8.6. Создание собственных modules".

## Q/A

### Задание 1

> Подготовка к выполнению
> 1. Создайте пустой публичных репозиторий в любом своём проекте: `my_own_collection`
> 2. Скачайте репозиторий ansible: `git clone https://github.com/ansible/ansible.git` по любому удобному вам пути
> 3. Зайдите в директорию ansible: `cd ansible`
> 4. Создайте виртуальное окружение: `python3 -m venv venv`
> 5. Активируйте виртуальное окружение: `./venv/bin/activate`. Дальнейшие действия производятся только в виртуальном окружении
> 6. Установите зависимости `pip install -r requirements.txt`
> 7. Запустить настройку окружения `./hacking/env-setup`
> 8. Если все шаги прошли успешно - выйти из виртуального окружения `deactivate`
> 9. Ваше окружение настроено, для того чтобы запустить его, нужно находиться в директории `ansible` и выполнить конструкцию `./venv/bin/activate && ./hacking/env-setup`

Репозиторий: [Dannecron/netology-devops-ansible-yandex-cloud-cvl](https://github.com/Dannecron/netology-devops-ansible-yandex-cloud-cvl).

Дополнительные действия:
1. В ubuntu-дистрибутивах модуль `venv` не установлен по умолчанию, поэтому нужно его установить самостоятельно

   ```shell
   sudo apt install python3.8-venv
   ```

2. Напрямую вызвать `./venv/bin/activate` нельзя, он не исполняемый. Внутри файла описан комментарий

    ```text
    This file must be used with "source bin/activate" *from bash*
    you cannot run it directly
    ```
   
    Поэтому нужно запустить следующую команду:

    ```shell
    source ./venv/bin/activate
    ```

3. Аналогично с запуском `./hacking/env-setup`

    ```shell
    source ./hacking/env-setup
    ```

### Задание 2

> Основная часть
> Наша цель - написать собственный module, который мы можем использовать в своей role, через playbook.
> Всё это должно быть собрано в виде collection и отправлено в наш репозиторий.
> 
> 1. В виртуальном окружении создать новый `my_own_module.py` файл
> 2. Наполнить его содержимым из [статьи](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html#creating-a-module)
> 3. Заполните файл в соответствии с требованиями ansible так, чтобы он выполнял основную задачу: module должен создавать текстовый файл на удалённом хосте по пути, 
> определённом в параметре `path`, с содержимым, определённым в параметре `content`.

Код модуля доступен в файле [my_own_module.py](./module/my_own_module.py). Внутри репозитория `ansible` его
необходимо положить по пути `lib/ansible/modules`.

> 4. Проверьте module на исполняемость локально

Нужно создать в корне репозитория `ansible` файл `payload.json` со следующим содержимым:

```json
{
    "ANSIBLE_MODULE_ARGS": {
        "path": "/tmp/new",
        "content": "some content"
    }
}
```

Затем нужно выполнить следующую команду:

```shell
python3 -m ansible.modules.my_own_module payload.json
```

```json
{"changed": true, "invocation": {"module_args": {"path": "/tmp/new", "content": "some content"}}}
```

При первом запуске модуль создаст файл:

```shell
cat /tmp/new
```

```text
some content
```

При втором вызове модуля ничего не изменится:

```shell
python3 -m ansible.modules.my_own_module payload.json
```

```text
{"changed": false, "invocation": {"module_args": {"path": "/tmp/new", "content": "some content"}}}
```

> 5. Напишите single task playbook и используйте module в нём.
> 6. Проверьте через playbook на идемпотентность
> 7. Выйдите из виртуального окружения

Playbook будет выглядеть следующим образом: [test_module.yml](./module/test_module.yml).
Данный файл нужно положить в корень репозитория `ansible` и выполнить следующую команду:

```shell
ansible-playbook test_module.yml
```

```text
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does
not match 'all'

PLAY [test my own module] ************************************************************************************
TASK [Gathering Facts] ***************************************************************************************
ok: [localhost]

TASK [create file] *******************************************************************************************
changed: [localhost]

PLAY RECAP ***************************************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Повторим запуск, чтобы проверить идемпотентность:

```shell
ansible-playbook test_module.yml
```

```text
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does
not match 'all'

PLAY [test my own module] ************************************************************************************
TASK [Gathering Facts] ***************************************************************************************
ok: [localhost]

TASK [create file] *******************************************************************************************
ok: [localhost]

PLAY RECAP ***************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Выход из виртуального окружения:

```shell
deactivate
```

> 8. Инициализируйте новую collection: `ansible-galaxy collection init my_own_namespace.yandex_cloud_cvl`.

```shell
ansible-galaxy collection init my_own_namespace.yandex_cloud_cvl
```

```text
- Collection my_own_namespace.yandex_cloud_cvl was created successfully
```

Новая коллекция сразу перенесена в репозиторий [netology-devops-ansible-yandex-cloud-cvl](https://github.com/Dannecron/netology-devops-ansible-yandex-cloud-cvl).

> 9. В данную collection перенесите свой module в соответствующую директорию.

Модуль размещён в директории `modules` в репозитории [netology-devops-ansible-yandex-cloud-cvl](https://github.com/Dannecron/netology-devops-ansible-yandex-cloud-cvl).

> 10. Single task playbook преобразуйте в single task role и перенесите в collection.
> У role должны быть default всех параметров module

Роль размещена в директории `my_own_role` в репозитории [netology-devops-ansible-yandex-cloud-cvl](https://github.com/Dannecron/netology-devops-ansible-yandex-cloud-cvl).

> 11. Создайте playbook для использования этой role

Playbook для работы с ролью расположен в файле [playbook/my_playbook.yml](./playbook/my_playbook.yml).

> 12. Заполните всю документацию по collection, выложите в свой репозиторий, поставьте тег `1.0.0` на этот коммит.

[netology-devops-ansible-yandex-cloud-cvl:1.0.0](https://github.com/Dannecron/netology-devops-ansible-yandex-cloud-cvl/releases/tag/1.0.0).

> 13. Создайте .tar.gz этой collection: `ansible-galaxy collection build` в корневой директории collection.

```shell
ansible-galaxy collection build
```

```text
Created collection for my_own_namespace.yandex_cloud_cvl at netology-devops-ansible-yandex-cloud-cvl/my_own_namespace-yandex_cloud_cvl-1.0.0.tar.gz
```

> 14. Создайте ещё одну директорию любого наименования, перенесите туда single task playbook и архив c collection.

Директория с playbook, который создан на шаге 11. 

> 15. Установите collection из локального архива: `ansible-galaxy collection install <archivename>.tar.gz`

```shell
ansible-galaxy collection install my_own_namespace-yandex_cloud_cvl-1.0.0.tar.gz
```

```text
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Installing 'my_own_namespace.yandex_cloud_cvl:1.0.0' to '~/.ansible/collections/ansible_collections/my_own_namespace/yandex_cloud_cvl'
my_own_namespace.yandex_cloud_cvl:1.0.0 was installed successfully
```

> 16. Запустите playbook, убедитесь, что он работает.

```shell
ansible-playbook my_playbook.yml
```

```text
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does
not match 'all'

PLAY [my playbook] *****************************************************************************************
TASK [Gathering Facts] *************************************************************************************
ok: [localhost]

TASK [my_own_namespace.yandex_cloud_cvl.my_own_role : create file] *****************************************
changed: [localhost]

PLAY RECAP *************************************************************************************************
localhost            : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```
