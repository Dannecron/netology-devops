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
