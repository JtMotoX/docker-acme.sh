#!/bin/sh

docker run --rm -it -v /docker/acme-sh/acme-logs:/var/log/acme-logs -v /docker/acme-sh/acme.sh:/acme.sh neilpang/acme.sh:latest ash