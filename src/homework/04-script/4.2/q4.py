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
