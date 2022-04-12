#!/usr/bin/env bash

serverPort=80
servers=("192.168.0.1" "173.194.222.113" "87.250.250.242")

for i in {1..5}
do
  for server in ${servers[@]}
  do
    curl --connect-timeout 3 --max-time 5 http://${server}:${serverPort}
    curlResult=$?
    echo "$(date) curl result for ${server} is ${curlResult}" >> curl.log;
  done
done
