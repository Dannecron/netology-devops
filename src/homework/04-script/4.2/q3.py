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
