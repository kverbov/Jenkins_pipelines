#!/bin/bash

# This script's purpose is to replace upstream image's ENTRYPOINT (that just calls /docker-entrypoint.sh).
# Instead we do these steps:
# 1. source envs from file (mounted into /kafka/mounted/.envs).

set -a
    source /kafka/mounted/.envs
set +a

# 2. Write extra properties (if any) from mounted extra.worker.properties file to base image's configs.

cat /kafka/mounted/extra.connect-distributed.properties >> "${KAFKA_HOME}"/config.orig/connect-distributed.properties

cp --copy-contents -f /kafka/mounted/log4j.properties "${KAFKA_HOME}"/config/log4j.properties

#[ In parallel:
    # 3. call configure.connector.sh (in parallel with next step), which sleeps until worker becomes up and configurable, then configures the connectors and dies.

nohup "${KAFKA_HOME}"/bin/configure.connector.sh >/dev/null 2>&1 &
disown

    # 4. call upstream image's docker-entrypoint.sh (completely unmodified) to start worker.

exec /docker-entrypoint.sh "${@}"

#]
