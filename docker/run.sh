#!/bin/sh

set -e

if [ -d /mnt/proc ]; then
  umount /proc
  mount -o bind /mnt/proc /proc
fi

export GRAPHITE_PORT=${GRAPHITE_PORT:-2003}
export GRAPHITE_PREFIX=${GRAPHITE_PREFIX:-collectd.}
export COLLECTD_INTERVAL=${COLLECTD_INTERVAL:-10}
export MYSQL_HOST=${MYSQL_PORT:-localhost}
export MYSQL_USER=${MYSQL_USER:-root}
export MYSQL_PASSWORD=${MYSQL_PASSWORD:-password}

# Adding a user if needed to be able to communicate with docker
GROUP=nobody
if [ -e /var/run/docker.sock ]; then
  GROUP=$(ls -l /var/run/docker.sock | awk '{ print $4 }')

  # make sure group exists
  if [ ! $(getent group "$GROUP") ]; then
    # group doesn't exist, must be group id, create new group with same id
    GROUP_ID=$GROUP
    GROUP="docker_${GROUP_ID}"
    groupadd -g $GROUP_ID $GROUP
  fi
fi

# if user not exists, add him
if [ ! $(getent passwd "collectd-docker-collector") ]; then
  useradd -g "${GROUP}" collectd-docker-collector
fi

exec reefer -t /etc/collectd/collectd.conf.tpl:/tmp/collectd.conf -E \
  collectd -f -C /tmp/collectd.conf "$@" > /dev/null
