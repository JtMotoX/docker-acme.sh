#!/bin/sh

set -e

# CONVERT 1PASSWORD ENVIRONMENT VARIABLES
if env | grep -E '^[^=]*=OP:' >/dev/null; then
	curl -sS -o /tmp/1password-vars.sh "https://raw.githubusercontent.com/JtMotoX/1password-docker/main/1password/op-vars.sh"
	chmod 755 /tmp/1password-vars.sh
	. /tmp/1password-vars.sh || exit 1
	rm -f /tmp/1password-vars.sh
fi

if [ "$1" = "run" ]; then
	# MAKE SURE WE HAVE ACCESS TO ACME FILES
	ACME_DIR="/acme.sh"
	ACME_FILES=$(find ${ACME_DIR} ! -user $(id -u) 2>/dev/null)
	if [ $? -ne 0 ] || [ "${ACME_FILES}" != "" ]; then
		echo "ERROR: Access denied to 'acme.sh' directory"
		echo "note: 'chown -R $(id -u):$(id -g) acme.sh'"
		exit 1
	fi

	# MAKE SURE WE HAVE ACCESS TO LOG FILES
	LOGS_DIR="/var/log/acme-logs"
	LOG_FILES=$(find ${LOGS_DIR} ! -user $(id -u) 2>/dev/null)
	if [ $? -ne 0 ] || [ "${LOG_FILES}" != "" ]; then
		echo "ERROR: Access denied to 'acme-logs' directory"
		echo "note: 'chown -R $(id -u):$(id -g) acme-logs'"
		exit 1
	fi

	# SET ACME SERVER IF DEFINED
	test -n "${ACME_SERVER+set}" && acme.sh --set-default-ca --server ${ACME_SERVER}

	# START CRON
	echo "Starting cron . . ."
	inotifywait -q -m -e close_write --format %e "${CRONTAB_FILE}" | while read events; do supercronic -test "${CRONTAB_FILE}" && killall -SIGUSR2 supercronic; done &
	supercronic "${CRONTAB_FILE}"

	echo "ERROR: Looks like supercronic crashed"
	exit 1
fi

exec "$@"
