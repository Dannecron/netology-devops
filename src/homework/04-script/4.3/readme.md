Выполнение [домашнего задания](https://github.com/netology-code/sysadm-homeworks/blob/devsys10/04-script-03-yaml/README.md) 
по теме "4.3. Языки разметки JSON и YAML".

## Q/A

### Обязательная задача 1

Мы выгрузили JSON, который получили через API запрос к нашему сервису:

```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```

Нужно найти и исправить все ошибки, которые допускает наш сервис.

Решение:

```json
{ 
  "info": "Sample JSON output from our service\t",
  "elements": [
    {
      "name": "first",
      "type": "server",
      "ip": 7175 
    },
    {
      "name": "second",
      "type": "proxy",
      "ip": "71.78.22.43"
    }
  ]
}
```

### Обязательная задача 2

В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. 
К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы.
Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`.
Формат записи YAML по одному сервису: `- имя сервиса: его IP`.
Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

#### Ваш скрипт:

[script](./q2.py)

```python
#!/usr/bin/env python3

import json
import io
import os
import socket
import yaml

hosts_list = {
    "drive.google.com",
    "mail.google.com",
    "google.com"
}

filename_json = 'hosts.json'
filename_yaml = 'hosts.yaml'

if not os.path.exists(filename_json):
    os.mknod(filename_json)

if not os.path.exists(filename_yaml):
    os.mknod(filename_yaml)

file_json = None
file_yaml = None

try:
    file_json = open(filename_json, 'r+')
    file_yaml = open(filename_yaml, 'r+')

    json_str = file_json.read()
    try:
        json_obj = json.load(io.StringIO(json_str))
    except BaseException as err:
        json_obj = dict({})
        print('error: {}'.format(err))

    for hostname in hosts_list:
        ip_addr = socket.gethostbyname(hostname)
        prev_ip_addr = json_obj.get(hostname)

        if prev_ip_addr is None or prev_ip_addr == '':
            prev_ip_addr = ip_addr

        print('{} - {}'.format(hostname, ip_addr))
        if ip_addr != prev_ip_addr:
            print('[ERROR] {} IP mismatch: {} {}'.format(hostname, ip_addr, prev_ip_addr))

        json_obj[hostname] = ip_addr

    file_json.truncate(0)
    file_json.seek(0)
    file_json.write(json.dumps(json_obj))

    file_yaml.truncate(0)
    file_yaml.seek(0)
    file_yaml.write(yaml.dump(json_obj))
except BaseException as err:
    print('error {}'.format(err))
finally:
    if file_json is not None:
        file_json.close()

    if file_yaml is not None:
        file_yaml.close()

```

#### Вывод скрипта при запуске при тестировании:

```shell
./q2.py
error: Expecting value: line 1 column 1 (char 0)
mail.google.com - 64.233.162.17
google.com - 74.125.205.102
drive.google.com - 142.250.150.194
```

#### json-файл(ы), который(е) записал ваш скрипт:

```json
{"mail.google.com": "64.233.162.17", "google.com": "74.125.205.102", "drive.google.com": "142.250.150.194"}
```

#### yml-файл(ы), который(е) записал ваш скрипт:

```yaml
drive.google.com: 142.250.150.194
google.com: 74.125.205.102
mail.google.com: 64.233.162.17
```
