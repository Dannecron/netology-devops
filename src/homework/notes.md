# Git

## Git new commands

В git постепенно появляются алиасы, чтобы команды становились узконаправленными. Новые полезные команды:
1. [`git restore`](https://git-scm.com/docs/git-restore) - восстановление файлов в рабочей директории (например, откат изменений как при использовании `git checkout -- .`)
2. [`git switch`](https://git-scm.com/docs/git-switch) - переключение веток. Более узконаправленная команда, чем `git checkout` или `git branch`.

## Git rebase

Примерный порядок действий перебазирования веток в `main`:
1. `git switch new-branch`
2. `git rebase main`
3. _optional_ исправление конфликтов, выполнение команды `git rebase --continue`
4. `git checkout main`
5. `git merge new-branch`
6. `git branch -D new-branch`

# Linux operating system

## Streams

Базовые потоки:
* `0` - stdin (`/proc/<pid>/fd/0`)
* `1` - stdout (`/proc/<pid>/fd/1`)
* `2` - stderr (`/proc/<pid>/fd/2`)

Для перенаправления потока можно использовать `X>&Y`, где `X` поток, который нужно перенаправить,
`Y` - поток, в который нужно направить данные (может быть стандартным файлом).

## Kernel

Версия ядра: `uname -r`.
Версия дистрибутива: `cat /etc/issue` (debian-based), `cat /etc/redhat-release` (centos-based).

Посмотреть всю конфигурацию системы: `sysctl -a`.

Логи системы: `dmesg`, `syslog`.

## Systemctl

* `systemctl list-units --all`
* `systemctl status <service>`
* `systemctl cat <service>` - просмотреть файл настроек сервиса
* `systemctl list-dependencies <service>`
  ```shell
  systemctl list-dependencies docker

  docker.service
  ● ├─containerd.service
  ● ├─docker.socket
  ● ├─system.slice
  ● ├─network-online.target
  ● │ └─NetworkManager-wait-online.service
  ● └─sysinit.target
  ●   ├─apparmor.service
  <...>
  ```
* `journalctl -f`
* `journalctl -f -u docker`

## Filesystems

* `stat <file>`

### File types

* regular file (`ls -la` - `-`)
* directory (`ls -la` - `d`)
* hardlink (`ls -la` - `l`)

  1 файл - 1 hardlink
  1 директрория - минимум 2 hardlink (у пустой директории - 2, +1 за каждую директорию внутри)

* symlink (`ls -la` - `l`)
* pipe (`ls -la` - `p`)
    
  Перенаправление потоков, только однонаправленный
  `mkfifo <pipe>`

* socket (`ls -la` - `s`)
  
  Двунаправленный поток, производительнее, чем pipe. Используется для взаимодействия между процессами.

### File access

`chown`, `chmod`, `umask`

Права по умолчанию:
* `file`: `666 - umask`
* `dir`: `777 - umask`

Дополнительные права доступа:
* `sticky` - создание доступно всем, удаление только файлы пользователя
* `setuid`
* `setgid`

`lsattr`/`chattr`

### Raid

`mdadm`

### LVM 

`lvs`, `vgs`, `vgdisplay`, `pvdisplay`

### Partitions

`fdisk -l`/`fdisk`, `sfdisk`

### Filesystems

`mkfs`, `mount`, `/etc/fstab`