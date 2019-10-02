#! /bin/bash

# Bootstraps the mongo server.

set -e

export PATH="$PATH:/opt/rancher/bin"

MONGO_PORT=${MONGO_PORT:-27017}
MONGO_DIR=${MONGO_DIR:-/data/db}
MONGO_STORAGE_ENGINE=${MONGO_STORAGE_ENGINE:-wiredTiger}
MONGO_OPTS=${MONGO_OPTS}

MONGO_USER=${MONGO_INITDB_ROOT_USERNAME}
MONGO_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}

MONGO_REPLSET=${MONGO_REPLSET}
MONGO_ROLE=${MONGO_ROLE}
MONGO_KEYFILE=${MONGO_KEYFILE}

MONGO_DROP_DATABASE=${MONGO_DROP_DATABASE}

if [[ "${DEBUG}" == "" ]]; then
  QUIET="--quiet"
fi

if [[ "${MONGO_USER}" != "" && "${MONGO_PASSWORD}" != "" ]]; then
  if [[ "${MONGO_REPLSET}" != "" && "${MONGO_KEYFILE}" == "" ]]; then
    echo "MONGO_KEYFILE must be specified for replset authentication"
    exit 1
  elif [[ "${MONGO_REPLSET}" != "" ]]; then
    AUTH="--auth --keyFile ${MONGO_KEYFILE}"
  else
    AUTH="--auth"
  fi
fi

# Wait for MONGO_DIR
while [[ ! -e ${MONGO_DIR} ]]; do
  echo "Waiting for mongo dir..."
  sleep 1
done

# Wait for MONGO_KEYFILE
while [[ "$MONGO_KEYFILE" != "" && ! -e ${MONGO_KEYFILE} ]]; do
  echo "Waiting for mongo keyfile..."
  sleep 1
done
chown -R mongodb:mongodb ${MONGO_KEYFILE} || true
chmod 600 ${MONGO_KEYFILE} || true

if [[ "${MONGO_DROP_DATABASE}" != "" ]]; then
  rm -rf ${MONGO_DIR}/data
fi

# Initialize database
chown -R mongodb:mongodb ${MONGO_DIR}
if [[ ! -e ${MONGO_DIR}/data ]]; then
  mkdir -p ${MONGO_DIR}/data &> /dev/null
  chown -R mongodb:mongodb ${MONGO_DIR}

  # Start init process to setup default accounts
  mongo-init
  mongo-init-cleanup &
fi

if [[ "$MONGO_REPLSET" != "" ]]; then
  ARBITER_OPTS=
  if [[ "$MONGO_ROLE" == "arbiter" ]]; then
    ARBITER_OPTS="--smallfiles"
  fi
  exec gosu mongodb mongod \
    --bind_ip_all \
    --storageEngine ${MONGO_STORAGE_ENGINE} \
    --dbpath ${MONGO_DIR}/data \
    --port ${MONGO_PORT} \
    --replSet ${MONGO_REPLSET} \
    ${AUTH} \
    ${QUIET} \
    ${ARBITER_OPTS} \
    ${MONGO_OPTS}
else
  exec gosu mongodb mongod \
    --bind_ip_all \
    --storageEngine ${MONGO_STORAGE_ENGINE} \
    --dbpath ${MONGO_DIR}/data \
    --port ${MONGO_PORT} \
    ${AUTH} \
    ${QUIET} \
    ${MONGO_OPTS}
fi
