docker run --rm -d --name=centos7 centos:7  tail -f /dev/null \
  && docker run --rm -d --name=debian debian:stable-slim tail -f /dev/null
