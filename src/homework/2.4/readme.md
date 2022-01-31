Выполнение [домашнего задания](https://github.com/netology-code/sysadm-homeworks/blob/devsys10/02-git-04-tools/README.md) по теме "Инструменты Git".

## Git search

- Какому тегу соответствует коммит `85024d3`?

Для поиска информации о коммите можно использовать функцию `git show`. Вывод краткой информации о коммите в саму консоль:

```shell
git --no-pager show --oneline -s 85024d3
85024d310 (tag: v0.12.23) v0.12.23
```

где: `--no-pager` - отключает открытие информации в отдельной утилите, `-s` - убирает информацию о `diff`.

Ответ: `v0.12.23`

- Сколько родителей у коммита `b8d720`? Напишите их хеши.

Есть два способа найти необходимую информацию: через `git show` или через `git log`.

Для вывода информации через `git show` нужно описать определённый формат для отображения:
```shell
git --no-pager show --pretty=format:"commit: %h%nparents: %p%n" -s b8d720
commit: b8d720f83
parents: 56cd7859e 9ea88f22f
```

Для вывода информации через `git log` нужно по аналогии с `git show` описать формат для отображения:

```shell
git --no-pager log --pretty="commit: %h%nparents: %p%n" --graph -n 1 b8d720
*   commit: b8d720f83
|\  parents: 56cd7859e 9ea88f22f
| | 
```

Ответ: 2 родителя с хэшами `56cd7859e` и `9ea88f22f`.

- Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами `v0.12.23` и `v0.12.24`.

Вывод данной информации возможен через команду `git log`. Чтобы включить в отображение сам коммит, к которому создана первая версия, нужно добавить `^`.

```shell
git log --oneline --graph v0.12.23^..v0.12.24
* 33ff1c03b (tag: v0.12.24) v0.12.24
* b14b74c49 [Website] vmc provider links
* 3f235065b Update CHANGELOG.md
* 6ae64e247 registry: Fix panic when server is unreachable
* 5c619ca1b website: Remove links to the getting started guide's old location
* 06275647e Update CHANGELOG.md
* d5f9411f5 command: Fix bug when using terraform login on Windows
* 4b6d06cc5 Update CHANGELOG.md
* dd01a3507 Update CHANGELOG.md
* 225466bc3 Cleanup after v0.12.23 release
* 85024d310 (tag: v0.12.23) v0.12.23
```

Ответ:

| commit    | comment                                                           |
|-----------|-------------------------------------------------------------------|
| b14b74c49 | [Website] vmc provider links                                      |
| 3f235065b | Update CHANGELOG.md                                               |
| 6ae64e247 | registry: Fix panic when server is unreachable                    |
| 5c619ca1b | website: Remove links to the getting started guide's old location |
| 06275647e | Update CHANGELOG.md                                               |
| d5f9411f5 | command: Fix bug when using terraform login on Windows            |
| 4b6d06cc5 | Update CHANGELOG.md                                               |
| dd01a3507 | Update CHANGELOG.md                                               |
| 225466bc3 | Cleanup after v0.12.23 release                                    |

- Найдите коммит в котором была создана функция `func providerSource`, ее определение в коде выглядит так `func providerSource(...)` (вместо троеточия перечислены аргументы).

Для поиска самого раннего коммита воспользуемся возможностью команды `git log` искать содержимое по регулярному выражению (флаг `-G`).

```shell
git --no-pager log --oneline -G"func providerSource(.*)"
f5012c12d command/cliconfig: Installation methods, not installation sources
5af1e6234 main: Honor explicit provider_installation CLI config when present
8c928e835 main: Consult local directories as potential mirrors of providers
```

Проверить правильность поиска можно посмотрев все изменения в коммите:
```shell
git show 8c928e835
```

Ответ: `8c928e835`

- Найдите все коммиты в которых была изменена функция `globalPluginDirs`

По аналогии с предыдущим пунктом:

```shell
git --no-pager log --oneline -G"func globalPluginDirs(.*)"
8364383c3 Push plugin discovery down into command package
```

Ответ: после добавления функции её изменений не было.

- Кто автор функции `synchronizedWriters`?

По аналогии с предыдущим пунктом используем функцию `git log`, только изменим формат отображения на `short`:

```shell
git --no-pager log --pretty=short -G"func synchronizedWriters(.*)"
commit bdfea50cc85161dea41be0fe3381fd98731ff786
Author: James Bardin <j.bardin@gmail.com>

    remove unused

commit 5ac311e2a91e381e2f52234668b49ba670aa0fe5
Author: Martin Atkins <mart@degeneration.co.uk>

    main: synchronize writes to VT100-faker on Windows
```

Ответ: `Martin Atkins`