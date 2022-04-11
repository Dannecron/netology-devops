Выполнение [домашнего задания](https://github.com/netology-code/sysadm-homeworks/blob/devsys10/04-script-02-py/README.md) 
по теме "4.2. Использование Python для решения типовых DevOps задач".

## Q/A

### Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

#### Вопросы:
| Вопрос                                         | Ответ                                                                                                                                                                                                          |
|------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Какое значение будет присвоено переменной `c`? | Переменной не будет присвоено никакое значение, потому что производится сложение целого числа и строки, при этом будет инициировано исключение `TypeError: unsupported operand type(s) for +: 'int' and 'str'` |
| Как получить для переменной `c` значение 12?   | Для этого необходимо присвоить переменной `a` строковое значение `'1'`, чтобы была произведена конкатенация строк. [script](./q1_2.py)                                                                         |
| Как получить для переменной `c` значение 3?    | Для этого необходимо присвоить переменной `b` целочисленное значение `2` (без кавычек). [script](./q1_3.py)                                                                                                    |

### Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

#### Ваш скрипт:

[script](./q2.py)

```python
#!/usr/bin/env python3

import os
cd_command = "cd ~/netology/sysadm-homeworks"
bash_command = [cd_command, "git status"]
top_level_command = [cd_command, "git rev-parse --show-toplevel"]
top_level = os.popen(' && '.join(top_level_command)).read().replace('\n', '')
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        full_path = top_level + '/' + prepare_result
        print(full_path)
```

#### Вывод скрипта при запуске при тестировании:

_note_: при запуске скрипта изменил путь до репозитория.
```
./q2.py
/home/dannc/code/learning/netology/readme.md
/home/dannc/code/learning/netology/src/homework/04-script/4.2/q1_2.py
/home/dannc/code/learning/netology/src/homework/04-script/4.2/q1_3.py
/home/dannc/code/learning/netology/src/homework/04-script/4.2/q2.py
/home/dannc/code/learning/netology/src/homework/04-script/4.2/readme.md

```

### Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

#### Ваш скрипт:

[script](./q3.py)

```python
#!/usr/bin/env python3

import os
import subprocess
import sys

repo_path = sys.argv[1]

if repo_path == '':
    print('необходимо указать путь до локального репозитория')
    exit(1)

# запускаем под-процесс в рабочей директории (cwd)
top_level_command = subprocess.Popen(
    ['git rev-parse --show-toplevel'],
    cwd=repo_path,
    shell=True,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
)

# ожидаем выполнение под-процесса
top_level_command.wait()
if top_level_command.returncode != 0:
    print('директория {} не является git-репозиторием'.format(repo_path))
    exit(1)

# на выходе у read() идёт последовательность байт, которые необходимо декодировать в строку
top_level_path = top_level_command.stdout.read().decode("utf-8").rstrip()

bash_command = ['cd ' + top_level_path, "git status"]

result_os = os.popen(' && '.join(bash_command)).read()

for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        full_path = top_level_path + '/' + prepare_result
        print(full_path)

```

#### Вывод скрипта при запуске при тестировании:
```
./q3.py ~/code/learning/netology
/home/dannc/code/learning/netology/src/homework/04-script/4.2/q3.py
```

### Обязательная задача 4
Наша команда разрабатывает несколько веб-сервисов, доступных по http.
Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера,
где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера,
поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. 
Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании,
который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP,
выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>.
Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки.
Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>.
Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

#### Ваш скрипт:

[script](./q4.py)

```python
#!/usr/bin/env python3

import json
import io
import socket

filename = 'hosts.json'

hostsList = {
    "drive.google.com",
    "mail.google.com",
    "google.com"
}

with open(filename, 'r+') as file:
    jsonStr = file.read()
    try:
        jsonObj = json.load(io.StringIO(jsonStr))
    except BaseException as err:
        jsonObj = dict({})
        print('error {}'.format(err))
        exit(1)

    file.truncate(0)
    file.seek(0)

    for hostname in hostsList:
        ipAddr = socket.gethostbyname(hostname)
        prevIpAddr = jsonObj.get(hostname)

        if prevIpAddr is None or prevIpAddr == '':
            prevIpAddr = ipAddr

        print('{} - {}'.format(hostname, ipAddr))
        if ipAddr != prevIpAddr:
            print('[ERROR] {} IP mismatch: {} {}'.format(hostname, ipAddr, prevIpAddr))

        jsonObj[hostname] = ipAddr

    file.write(json.dumps(jsonObj))
```

#### Вывод скрипта при запуске при тестировании:

Предположим, что в какой-то момент времени были следующие значения ip-адресов серверов:

```json
{"drive.google.com": "173.194.221.194", "mail.google.com": "142.251.1.18", "google.com": "64.233.162.139"}
```

Тогда запуск команды будет выглядеть следующим образом:

```
./q4.py
mail.google.com - 173.194.221.17
[ERROR] mail.google.com IP mismatch: 173.194.221.17 142.251.1.18
google.com - 64.233.162.100
[ERROR] google.com IP mismatch: 64.233.162.100 64.233.162.139
drive.google.com - 173.194.221.194
```
