docker run --rm -d --name=centos7 centos:7  tail -f /dev/null \
  && docker run --rm -d --name=debian python:slim tail -f /dev/null
