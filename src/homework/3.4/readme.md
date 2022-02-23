Выполнение [домашнего задания](https://github.com/netology-code/sysadm-homeworks/blob/devsys10/03-sysadmin-03-os/README.md) 
по теме "3.4. Операционные системы, лекция 2".

## Q/A

1. Создайте самостоятельно простой unit-файл для [node_exporter](https://github.com/prometheus/node_exporter)

Для начала необходимо установить `node_exporter` в систему. Для этого воспользуемся [официальным гайдом](https://prometheus.io/docs/guides/node-exporter/#installing-and-running-the-node-exporter),
а именно:

```shell
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz
cd node_exporter-1.3.1.linux-amd64
sudo mv node_exporter /usr/local/bin/
```

Проверим, что всё работает, выполнив команду

```shell
node_exporter --help

usage: node_exporter [<flags>]

Flags:
  -h, --help                     Show context-sensitive help (also try --help-long and --help-man).
<...>
```

Затем, создадим простой unit-файл по пути `/etc/systemd/system`:

```shell
sudo touch /etc/systemd/system/prometheus_node_exporter.service
```

И добавим в него следующее содержимое:

```unit file (systemd)
[Unit]
Description=Prometheuth node exporter service
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
User=vagrant
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

Затем запустим сервис, проверим, что он имеет статус "запущен", проверим работоспособность самого приложения и остановим выполнение:

```shell
sudo systemctl start prometheus_node_exporter
sudo systemctl status prometheus_node_exporter

● prometheus_node_exporter.service - Prometheuth node exporter service
     Loaded: loaded (/etc/systemd/system/prometheus_node_exporter.service; disabled; vendor preset: enabled)
     Active: active (running) since Wed 2022-02-23 03:52:14 UTC; 2s ago
   Main PID: 1520 (node_exporter)
      Tasks: 4 (limit: 1112)
     Memory: 2.2M
     CGroup: /system.slice/prometheus_node_exporter.service
             └─1520 /usr/local/bin/node_exporter

Feb 23 03:52:14 vagrant node_exporter[1520]: ts=2022-02-23T03:52:14.087Z caller=node_exporter.go:115 level=info collector=thermal_zone
Feb 23 03:52:14 vagrant node_exporter[1520]: ts=2022-02-23T03:52:14.087Z caller=node_exporter.go:115 level=info collector=time
<...>

curl -I http://localhost:9100/metrics

HTTP/1.1 200 OK
Content-Type: text/plain; version=0.0.4; charset=utf-8
Date: Wed, 23 Feb 2022 04:01:31 GMT

sudo systemctl stop prometheus_node_exporter
sudo systemctl status prometheus_node_exporter

sudo systemctl status prometheus_node_exporter
● prometheus_node_exporter.service - Prometheuth node exporter service
     Loaded: loaded (/etc/systemd/system/prometheus_node_exporter.service; disabled; vendor preset: enabled)
     Active: inactive (dead)

<...>
Feb 23 04:02:22 vagrant systemd[1]: Stopping Prometheuth node exporter service...
Feb 23 04:02:22 vagrant systemd[1]: prometheus_node_exporter.service: Succeeded.
Feb 23 04:02:22 vagrant systemd[1]: Stopped Prometheuth node exporter service.
```

Для добавления конфигурации через файл, необходимо создать файл с переменной окружения `EXTRA_OPTS`:

```shell
sudo mkdir -p /usr/local/lib/node_exporter
sudo touch /usr/local/lib/node_exporter/conf.env
sudo chmod +r /usr/local/lib/node_exporter/conf.env
echo "EXTRA_OPTS=--collector.cpu.info" | sudo tee /usr/local/lib/node_exporter/conf.env
```

Затем сделать изменения в unit-файле:
* В блок `[Service]` добавить новую строку `EnvironmentFile=-/usr/local/lib/node_exporter/conf.env`
* В ключ `ExecStart` после полного пути до приложения добавить вывод переменной окружения `$EXTRA_OPTS`

Далее проверить, что приложение запускается с дополнительным флагом:

```shell
sudo systemctl start prometheus_node_exporter
sudo systemctl status prometheus_node_exporter

● prometheus_node_exporter.service - Prometheuth node exporter service
     Loaded: loaded (/etc/systemd/system/prometheus_node_exporter.service; disabled; vendor preset: enabled)
     Active: active (running) since Wed 2022-02-23 04:18:07 UTC; 4s ago
   Main PID: 1820 (node_exporter)
      Tasks: 4 (limit: 1112)
     Memory: 2.3M
     CGroup: /system.slice/prometheus_node_exporter.service
             └─1820 /usr/local/bin/node_exporter --collector.cpu.info
<...>
```

2. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.

По умолчанию в `node_exporter` включено достаточно много различной информации (~1000 строк). Поэтому, на мой взгляд, 
для начала стоит включить только следующие флаги:
* `--collector.disable-defaults` - отключение всех коллекторов по умолчанию 
* `--collector.cpu` - отображение статистики по CPU
* `--collector.filesystem` - отображение статистики по файловой системе (например, количество использованного места)
* `--collector.meminfo` - отображение статистики по памяти
* `--collector.os` - отображение информации об операционной системе 
* `--collector.time` - отображение информации о текущем системном времени

3. Ознакомьтесь с метриками, которые по умолчанию собираются `Netdata`, и с комментариями, которые даны к этим метрикам.

`netdata` отображает следующие метрики:
* `cpu` - утилизация CPU по всем ядрам
* `load` - текущая загрузка системы (количество процессов, которые используют или ожидают различные системные ресурсы), поделённая на три усреднённых значения.
* `disk` - текущие показатели I/O для физических дисков
* `ram` - информация об оперативной памяти
* `swap` - информация о файлах подкачки
* `network` - информация о пропускной способности физических сетевых интерфейсов
* и другие

Доступны так же подробные графики по каждой из категорий.

4. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?

В `dmesg` можно найти следующий вывод `Detected virtualization oracle.` от `systemd`. Таким образом да, можно понять, что система осознаёт,
что находится внутри виртуальной машины, а не на физическом оборудовании.

5. Как настроен sysctl fs.nr_open на системе по-умолчанию? Какой другой существующий лимит не позволит достичь такого числа?

// todo

6. Запустите любой долгоживущий процесс в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`.

// todo 

7. Найдите информацию о том, что такое `:(){ :|:& };:`.
  Запустите эту команду в своей виртуальной машине. Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться.
  Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации.
  Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?

// todo



