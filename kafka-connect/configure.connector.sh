#!/bin/bash
set -xe

# Wait until port listener is up
listener="localhost:8083"
until curl -si "${listener}" | grep -q '200 OK'; do
	sleep 3
done

#{ Sanity checks
#if [[ -z "${CONNECTOR_TYPE}" ]]; then
#	echo "Envvar 'CONNECTOR_TYPE' is not defined, aborting."
#	exit 1
#fi
#if [[ -z "${CONNECTOR_NAME}" ]]; then
#	echo "Envvar 'CONNECTOR_NAME' is not defined, aborting."
#	exit 1
#fi
#if [[ -z "${ZOOKEEPER}" ]]; then
#	echo "Envvar 'ZOOKEEPER' is not defined, aborting."
#	exit 1
#fi
#}

# apply connector configs from json files
for config_file in /kafka/mounted/*.json; do
	[ -e "${config_file}" ] || continue
	connector="$(jq -r '.name' "${config_file}")"
	config="$(jq -r '.config' "${config_file}")"
	# put connector config (doesn't matter if it exists already or not)
	curl -sX PUT -H 'Accept: application/json' -H 'Content-Type: application/json' "${listener}/connectors/${connector}/config" -d "${config}"
done

sleep 2

# show connectors health status
for config_file in /kafka/mounted/*.json; do
	[ -e "${config_file}" ] || continue
	connector="$(jq -r '.name' "${config_file}")"
	curl -s "${listener}/connectors/${connector}/status" | jq -r '.tasks[0].state' 2>&1
done

#declare -a duty_topics=(
#	"rdbo.${STAND}.cdc.${SCHEMA_NAME}.configs"
#	"rdbo.${STAND}.cdc.${SCHEMA_NAME}.offsets"
#	"rdbo.${STAND}.cdc.${SCHEMA_NAME}.statuses"
#)

#for duty_topic in "${duty_topics[@]}"; do
#	"$KAFKA_HOME"/bin/kafka-configs.sh \
#		--zookeeper "${ZOOKEEPER}" \
#		--entity-type topics \
#		--entity-name "${duty_topic}" \
#		--alter \
#		--add-config retention.ms=-1
#done
