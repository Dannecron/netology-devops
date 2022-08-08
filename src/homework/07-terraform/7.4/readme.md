Выполнение [домашнего задания](https://github.com/netology-code/virt-homeworks/blob/master/07-terraform-04-teamwork/README.md)
по теме "7.4. Средства командной работы над инфраструктурой".

## Q/A

### Задание 1

> Настроить terraform cloud

Не выполнил, так как нет доступа и есть вероятность, что terraform cloud не будет работать с инфраструктурой `yandex.cloud`.

### Задание 2

> Написать серверный конфиг для атлантиса.
> 
> Смысл задания – познакомиться с документацией о [серверной](https://www.runatlantis.io/docs/server-side-repo-config.html) конфигурации
> и конфигурации уровня [репозитория](https://www.runatlantis.io/docs/repo-level-atlantis-yaml.html).
> 
> Создай `server.yaml` который скажет атлантису:
> 1. Укажите, что атлантис должен работать только для репозиториев в вашем github (или любом другом) аккаунте.
> 1. На стороне клиентского конфига разрешите изменять `workflow`, то есть для каждого репозитория можно
> будет указать свои дополнительные команды.
> 1. В `workflow` используемом по-умолчанию сделайте так, что бы во время планирования не происходил `lock` состояния.
> 
> Создай `atlantis.yaml` который, если поместить в корень terraform проекта, скажет атлантису:
> 1. Надо запускать планирование и аплай для двух воркспейсов `stage` и `prod`.
> 1. Необходимо включить автопланирование при изменении любых файлов `*.tf`.
> 
> В качестве результата приложите ссылку на файлы `server.yaml` и `atlantis.yaml`.

Создан файл [server.yaml](./atlantis/server.yaml) для конфигурации сервера, указанной в задании. А именно:
- `id:` - задаёт текущий репозиторий в качестве отслеживаемого `atlantis`.
- `allowed_overrides: [apply_requirements]` - указывает возможность изменения `workflow` на уровне репозитория.
- в ключе `workflows.default.plan` задаётся поведение команды `atlatis plan` по умолчанию для всех конфигураций.

В файле [atlantis.yaml](./atlantis/atlantis.yaml) добавлены два проекта, чтобы разграничить `workspace`, для которых применяются изменения.
При этом у каждого проекта определён массив `autoplan.when_modified`, в котором закреплено,
что необходимо автоматически запускать команды `terraform` при изменении любых файлов `*.tf`

### Задание 3

> Знакомство с каталогом модулей.
> 
> 1. В [каталоге модулей](https://registry.terraform.io/browse/modules) найдите готовый модуль для создания `yandex_compute_instance`.
> 2. Изучите как устроен модуль. Задумайтесь, будете ли в своем проекте использовать этот модуль или непосредственно
> ресурс `yandex_compute_instance` без помощи модуля?
> 3. В рамках предпоследнего задания был создан `yandex_compute_instance`.
> Создайте аналогичный инстанс при помощи найденного модуля.
> 
> В качестве результата задания приложите ссылку на созданный блок конфигураций.

В качестве готового модуля для `yandex.cloud` можно использовать [реализацию от hamnsk](https://registry.terraform.io/modules/hamnsk/vpc/yandex/latest).

В данном случае, лучше всего будет использовать напрямую `yandex_compute_instance`, так как лишние внешние зависимости только усложняют построение конфигурации.
Лучше всего будет взять за основу и переработать данный модуль "под себя". К тому же, из-за блокировки реестра terraform, использование модулей может быть затруднено.

Для инициализации данного модуля необходимо добавить следующий конфиг в [main.tf](./terraform/main.tf):

```terraform
module "yc-vpc" {
  name = terraform.workspace
  source  = "git@github.com:hamnsk/terraform-yandex-vpc.git?ref=v0.5.0"
  create_folder = false
  yc_folder_id = var.YC_FOLDER_ID
  yc_cloud_id = var.YC_CLOUD_ID
  nat_instance = true
  subnets = [
    {
      zone           = var.YC_ZONE
      v4_cidr_blocks = ["192.168.10.0/24"]
    }
  ]
}
```

При этом необходимо добавить новые переменные в [variables.tf](./terraform/variables.tf),
а так же инициализировать их новыми переменными окружения.

К сожалению, в данной конфигурации не получилось инициализировать данный модуль из-за ошибки:

```text
Error: failed to find latest image with family "nat-instance-ubuntu"
```

Выглядит это так, будто модуль опирается на образ ОС, которой теперь нет в реестре. Это ещё один пункт к тому,
что лучше самостоятельно создавать и поддерживать модули для `terraform`. 