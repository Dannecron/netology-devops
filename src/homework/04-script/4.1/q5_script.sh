#!/usr/bin/env bash

MSG="$1"

if ! grep -qE "^\[.+\]\s.+\n{0,1}$" "$MSG"
then
    cat "$MSG"
    echo $'\nYour commit message must match the pattern'
    exit 1
fi

msgStr=$(cat $MSG)
msgLen=${#msgStr}
if ((msgLen>50))
then
  cat "$MSG"
  echo $'\nYour commit message is too long'
  exit 1
fi