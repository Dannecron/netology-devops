Выполнение [домашнего задания](https://github.com/netology-code/mnt-homeworks/blob/MNT-13/08-ansible-04-role/README.md)
по теме "8.4. Работа с Roles".

## Q/A

### Задание 1

> Подготовка к выполнению
> 
> 1. (Необязательно) Познакомьтесь с [`lighthouse`](https://youtu.be/ymlrNlaHzIY?t=929)
> 2. Создайте два пустых публичных репозитория в любом своём проекте: vector-role и lighthouse-role.
> 3. Добавьте публичную часть своего ключа к своему профилю в github.

Заведены новые репозитории:
- [Dannecron/netology-devops-ansible-vector](https://github.com/Dannecron/netology-devops-ansible-vector)
- [Dannecron/netology-devops-ansible-lighthouse](https://github.com/Dannecron/netology-devops-ansible-lighthouse)

### Задание 2

> Основная часть
> 
> Наша основная цель - разбить наш playbook на отдельные roles. 
> Задача: сделать roles для clickhouse, vector и lighthouse и написать playbook для использования этих ролей. 
> Ожидаемый результат: существуют три ваших репозитория: два с roles и один с playbook.
> 
> 1. Создать в старой версии playbook файл `requirements.yml` и заполнить его следующим содержимым:
> 
>    ```yaml
>    ---
>    - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
>      scm: git
>      version: "1.11.0"
>      name: clickhouse 
>    ```

Создан файл [requirements.yml](./playbook/requirements.yml).

> 2. При помощи `ansible-galaxy` скачать себе эту роль.

```shell
ansible-galaxy install -r requirements.yml
```

```text
Starting galaxy role install process
- extracting clickhouse to ~/.ansible/roles/clickhouse
- clickhouse (1.13) was installed successfully
```

__Warning__: Внутри роли используются тэги `always`, которые нужно игнорировать (`--skip-tags always`),
если данная роль не будет запускаться в рамках playbook. 

> 4. Создать новый каталог с ролью при помощи `ansible-galaxy role init vector-role`.

```shell
ansible-galaxy role init vector-role
```

```text
- Role vector-role was created successfully
```

> 6. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`.

В `default` перенесены все текущие переменные (версия, путь до директории с конфигурацией, конфигурация),
так как эти переменные могут быть изменены для каждого отдельно взятого `playbook`.

Получается, что `vars` на данный момент останется пустым, так как нет таких переменных,
которые необходимы только внутри роли без возможности изменить их в `playbook`.

> 7. Перенести нужные шаблоны конфигов в `templates`.

В `templates` будут унесены два шаблона:
- `vector.config.j2`
- `vector.service.j2`

> 8. Описать в `README.md` обе роли и их параметры.

Описание добавлена в рамках репозитория с ролью: [readme.md](https://github.com/Dannecron/netology-devops-ansible-vector/blob/main/README.md)

> 9. Повторите шаги 3-6 для lighthouse. Помните, что одна роль должна настраивать один продукт.

Новая роль создана и расположена в репозитории [Dannecron/netology-devops-ansible-lighthouse](https://github.com/Dannecron/netology-devops-ansible-lighthouse).

Плюс, добавлена новая зависимость в [requirements.yml](./playbook/requirements.yml):

```yaml
- src: git@github.com:Dannecron/netology-devops-ansible-lighthouse.git
  scm: git
  version: "1.0.1"
  name: lighthouse
```

> 11. Выложите все roles в репозитории. Проставьте тэги, используя семантическую нумерацию. Добавьте roles в `requirements.yml` в playbook.
> 12. Переработайте playbook на использование roles. Не забудьте про зависимости lighthouse и возможности совмещения `roles` с `tasks`.
> 13. Выложите playbook в репозиторий.

[Playbook](./playbook/site.yml) был переработан на использование ролей.
