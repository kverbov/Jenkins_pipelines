#!/bin/bash

connectors="$(curl -sf localhost:8083/connectors/ | jq -r '.[]')"

while read -r connector; do
	#[ Safety check against 0 connectors
	if [[ -z "${connector}" ]]; then
		echo "[FAIL] No connectors found!"
		exit 1
	fi
	#]

	#[ Check connector's state
	connstate="$(curl -sf localhost:8083/connectors/"${connector}"/status)"

	if [[ "$(jq -r '.connector.state' <<< "${connstate}")" != 'RUNNING' ]]; then
		echo "[FAIL] Connector '${connector}' is not running!"
		exit 1
	fi
	#]
	
	#[ Check tasks states in each connector
	tasksstates="$(jq -r '.tasks[].state' <<< "${connstate}")"

	while read -r taskstate; do
		
		#[ Safety check against 0 tasks
		#if [[ -z "${taskstate}" ]]; then
		#	echo "[FAIL] No tasks found!"
		#	exit 1
		#fi
		#]
		
		#[ Check task's state
		if [[ "${taskstate}" != 'RUNNING' ]]; then
			echo "[FAIL] Connector '${connector}' has a task in state '${taskstate}', not 'RUNNING'!"
			exit 1
		fi
		#]
	done <<< "${tasksstates}"
	#]
done <<< "${connectors}"
