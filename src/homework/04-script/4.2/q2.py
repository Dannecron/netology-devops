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
