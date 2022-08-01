Выполнение [домашнего задания](https://github.com/netology-code/mnt-homeworks/blob/MNT-13/08-ansible-03-yandex/README.md)
по теме "8.3. Использование Yandex Cloud".

## Q/A

### Задание 1

> Подготовка к выполнению
> 1. Подготовьте в Yandex Cloud три хоста: для [clickhouse](https://clickhouse.com/), для [vector](https://vector.dev) и для [lighthouse](https://github.com/VKCOM/lighthouse)

Предыдущая итерация playbook с установкой `clickhouse` и `vector` перенесена в [playbook](./playbook) из [домашней работы 8.2](/src/homework/08-ansible/8.2).
Дополнительно для `vector` добавлены новые шаги с конфигурированием и запуском как systemd-сервис.

Новая группа хостов добавлена в [inventory/prod.yml.example](./playbook/inventory/prod.yml.example).

### Задание 2

> Основная часть
> 1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает lighthouse.
> 2. При создании tasks рекомендую использовать модули: get_url, template, yum, apt.
> 3. Tasks должны: скачать статику lighthouse, установить nginx или любой другой webserver, настроить его конфиг для открытия lighthouse, запустить webserver.

Установка и настройка `lighthose` будет производиться при помощи следующих шагов. При этом выполняется условие,
что один шаг - один `task`.

1. установим необходимые зависимости в систему: `git` и `epel-release` 
2. создадим директорию `/var/www` с правами для текущего пользователя для хранения web-сервисов
3. создадим директорию `/var/log/nginx` с правами для текущего пользователя для записи логов `nginx`
4. склонируем репозиторий `lighthouse`. Путь возьмём из переменной `lighthouse_vcs`.
5. сконфигурируем `SElinux`, чтобы `nginx` имел доступ до директории `/var/www` ([stackoverflow](https://stackoverflow.com/questions/22586166/why-does-nginx-return-a-403-even-though-all-permissions-are-set-properly#answer-26228135))
6. установим `nginx` официально рекомендуемым способом
7. скопируем на машину и заполним шаблон конфигурации `nginx`
8. скопируем на машину и заполним шаблон конфигурации web-сервиса `lighthouse` для `nginx`
9. запустим сервис `nginx`

> 4. Приготовьте свой собственный inventory файл prod.yml.
> 5. Запустите ansible-lint site.yml и исправьте ошибки, если они есть

Утилита `ansible-lint` не входит в стандартную поставку `ansible` и её необходимо установить отдельно:

```shell
pip3 install "ansible-lint" --user
```

Запуск линтера:

```shell
ansible-lint site.yml
```

```text
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
```
> 6. Попробуйте запустить playbook на этом окружении с флагом `--check`

```shell
ansible-playbook -i inventory/prod.yml site.yml --check
```

```text
 ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [clickhouse] ******************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [clickhouse-01]

TASK [clickhouse | get distrib noarch] *********************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-sta) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-sta-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-sta", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-sta-22.3.3.44.noarch.rpm"}

TASK [clickhouse | get distrib standard] *******************************************************************************
changed: [clickhouse-01]

TASK [clickhouse | install packages] ***********************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system"]}

PLAY RECAP *************************************************************************************************************
clickhouse-01              : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=1    ignored=0
```

`Play` по установке `clickhouse` прошел с ошибкой, так как при флаге `--check` реальных изменений не вносится,
а значит и файлы, необходимые для шага установки, не сохраняются.

> 7. Запустите playbook на prod.yml окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

```shell
ansible-playbook -i inventory/prod.yml site.yml --diff
```

```text
PLAY [clickhouse] ******************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [clickhouse-01]

TASK [clickhouse | get distrib noarch] *********************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-sta) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-sta-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-sta", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-sta-22.3.3.44.noarch.rpm"}

TASK [clickhouse | get distrib standard] *******************************************************************************
changed: [clickhouse-01]

TASK [clickhouse | install packages] ***********************************************************************************
changed: [clickhouse-01]

TASK [clickhouse | start service] **************************************************************************************
changed: [clickhouse-01]

TASK [clickhouse | create database] ************************************************************************************
changed: [clickhouse-01]

PLAY [lighthouse] ******************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [lighthouse-01]

TASK [lighthouse | install dependencies] *******************************************************************************
changed: [lighthouse-01]

TASK [lighthouse | create nginx site dir] ******************************************************************************
--- before
+++ after
@@ -1,6 +1,6 @@
 {
-    "group": 0,
-    "owner": 0,
+    "group": 1000,
+    "owner": 1000,
     "path": "/var/www",
-    "state": "absent"
+    "state": "directory"
 }

changed: [lighthouse-01]

TASK [lighthouse | create nginx log dir] *******************************************************************************
--- before
+++ after
@@ -1,6 +1,6 @@
 {
-    "group": 0,
-    "owner": 0,
+    "group": 1000,
+    "owner": 1000,
     "path": "/var/log/nginx",
-    "state": "absent"
+    "state": "directory"
 }

changed: [lighthouse-01]

TASK [lighthouse | clone repository] ***********************************************************************************
>> Newly checked out d701335c25cd1bb9b5155711190bad8ab852c2ce
changed: [lighthouse-01]

TASK [lighthouse | config selinux] *************************************************************************************
ok: [lighthouse-01]

TASK [lighthouse | install nginx] **************************************************************************************
changed: [lighthouse-01]

TASK [lighthouse | nginx template config] ******************************************************************************
--- before: /etc/nginx/nginx.conf
+++ after: ~/.ansible/tmp/ansible-local-17718geqlcqyp/tmpvwdezckg/nginx.conf.j2
@@ -1,17 +1,11 @@
-# For more information on configuration, see:
-#   * Official English Documentation: http://nginx.org/en/docs/
-#   * Official Russian Documentation: http://nginx.org/ru/docs/
+user  dannc;

-user nginx;
 worker_processes auto;
 error_log /var/log/nginx/error.log;
 pid /run/nginx.pid;

-# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
-include /usr/share/nginx/modules/*.conf;
-
 events {
-    worker_connections 1024;
+    worker_connections  1024;
 }

 http {
@@ -30,55 +24,5 @@
     include             /etc/nginx/mime.types;
     default_type        application/octet-stream;

-    # Load modular configuration files from the /etc/nginx/conf.d directory.
-    # See http://nginx.org/en/docs/ngx_core_module.html#include
-    # for more information.
     include /etc/nginx/conf.d/*.conf;
-
-    server {
-        listen       80;
-        listen       [::]:80;
-        server_name  _;
-        root         /usr/share/nginx/html;
-
-        # Load configuration files for the default server block.
-        include /etc/nginx/default.d/*.conf;
-
-        error_page 404 /404.html;
-        location = /404.html {
-        }
-
-        error_page 500 502 503 504 /50x.html;
-        location = /50x.html {
-        }
-    }
-
-# Settings for a TLS enabled server.
-#
-#    server {
-#        listen       443 ssl http2;
-#        listen       [::]:443 ssl http2;
-#        server_name  _;
-#        root         /usr/share/nginx/html;
-#
-#        ssl_certificate "/etc/pki/nginx/server.crt";
-#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
-#        ssl_session_cache shared:SSL:1m;
-#        ssl_session_timeout  10m;
-#        ssl_ciphers HIGH:!aNULL:!MD5;
-#        ssl_prefer_server_ciphers on;
-#
-#        # Load configuration files for the default server block.
-#        include /etc/nginx/default.d/*.conf;
-#
-#        error_page 404 /404.html;
-#            location = /40x.html {
-#        }
-#
-#        error_page 500 502 503 504 /50x.html;
-#            location = /50x.html {
-#        }
-#    }
-
 }
-

changed: [lighthouse-01]

TASK [lighthouse | nginx lighthouse config] ****************************************************************************
--- before
+++ after: ~/.ansible/tmp/ansible-local-17718geqlcqyp/tmp5ggb4hk2/nginx.lighthouse.conf.j2
@@ -0,0 +1,10 @@
+server {
+    listen 80;
+
+    access_log /var/log/nginx/lighthouse.log;
+
+    location / {
+        root /var/www/lighthouse;
+        index index.html;
+    }
+}

changed: [lighthouse-01]

TASK [lighthouse | start nginx service] ********************************************************************************
changed: [lighthouse-01]

TASK [lighthouse | check service is accessible] ************************************************************************
ok: [lighthouse-01]

PLAY [vector] **********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [vector-01]

TASK [vector | install archive manager] ********************************************************************************
ok: [vector-01]

TASK [vector | get distrib] ********************************************************************************************
changed: [vector-01]

TASK [vector | unpack distrib] *****************************************************************************************
changed: [vector-01]

TASK [vector | install] ************************************************************************************************
changed: [vector-01]

TASK [vector | check installed version] ********************************************************************************
ok: [vector-01]

TASK [vector | create data dir] ****************************************************************************************
--- before
+++ after
@@ -1,6 +1,6 @@
 {
-    "group": 0,
-    "owner": 0,
+    "group": 1000,
+    "owner": 1000,
     "path": "/var/lib/vector",
-    "state": "absent"
+    "state": "directory"
 }

changed: [vector-01]

TASK [vector | template config] ****************************************************************************************
--- before
+++ after: ~/.ansible/tmp/ansible-local-17718geqlcqyp/tmp227s1ei3/vector.config.j2
@@ -0,0 +1 @@
+data_dir: /var/lib/vector

changed: [vector-01]

TASK [vector | register as service] ************************************************************************************
--- before
+++ after: ~/.ansible/tmp/ansible-local-17718geqlcqyp/tmprmz1ok1o/vector.service.j2
@@ -0,0 +1,7 @@
+[Unit]
+Description=Vector service
+[Service]
+User=dannc
+Group=1000
+ExecStart=/usr/local/bin/vector --config-yaml /var/lib/vector/vector.yaml --watch-config
+Restart=always

changed: [vector-01]

TASK [vector | start service] ******************************************************************************************
changed: [vector-01]

PLAY RECAP *************************************************************************************************************
clickhouse-01              : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
lighthouse-01              : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
vector-01                  : ok=10   changed=7    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

> 8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

```shell
ansible-playbook -i inventory/prod.yml site.yml --diff
```

```text
PLAY [clickhouse] ******************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [clickhouse-01]

TASK [clickhouse | get distrib noarch] *********************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-sta) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-sta-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-sta", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-sta-22.3.3.44.noarch.rpm"}

TASK [clickhouse | get distrib standard] *******************************************************************************
ok: [clickhouse-01]

TASK [clickhouse | install packages] ***********************************************************************************
ok: [clickhouse-01]

TASK [clickhouse | start service] **************************************************************************************
changed: [clickhouse-01]

TASK [clickhouse | create database] ************************************************************************************
ok: [clickhouse-01]

PLAY [lighthouse] ******************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [lighthouse-01]

TASK [lighthouse | install dependencies] *******************************************************************************
ok: [lighthouse-01]

TASK [lighthouse | create nginx site dir] ******************************************************************************
ok: [lighthouse-01]

TASK [lighthouse | create nginx log dir] *******************************************************************************
ok: [lighthouse-01]

TASK [lighthouse | clone repository] ***********************************************************************************
ok: [lighthouse-01]

TASK [lighthouse | config selinux] *************************************************************************************
ok: [lighthouse-01]

TASK [lighthouse | install nginx] **************************************************************************************
ok: [lighthouse-01]

TASK [lighthouse | nginx template config] ******************************************************************************
ok: [lighthouse-01]

TASK [lighthouse | nginx lighthouse config] ****************************************************************************
ok: [lighthouse-01]

TASK [lighthouse | start nginx service] ********************************************************************************
ok: [lighthouse-01]

TASK [lighthouse | check service is accessible] ************************************************************************
ok: [lighthouse-01]

PLAY [vector] **********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [vector-01]

TASK [vector | install archive manager] ********************************************************************************
ok: [vector-01]

TASK [vector | get distrib] ********************************************************************************************
ok: [vector-01]

TASK [vector | unpack distrib] *****************************************************************************************
ok: [vector-01]

TASK [vector | install] ************************************************************************************************
ok: [vector-01]

TASK [vector | check installed version] ********************************************************************************
ok: [vector-01]

TASK [vector | create data dir] ****************************************************************************************
ok: [vector-01]

TASK [vector | template config] ****************************************************************************************
ok: [vector-01]

TASK [vector | register as service] ************************************************************************************
ok: [vector-01]

TASK [vector | start service] ******************************************************************************************
changed: [vector-01]

PLAY RECAP *************************************************************************************************************
clickhouse-01              : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
lighthouse-01              : ok=11   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
vector-01                  : ok=10   changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Изменения были только с работой сервисов, всё остальное выполняется идемпотентно.

> 9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

[readme.md](./playbook/readme.md)
