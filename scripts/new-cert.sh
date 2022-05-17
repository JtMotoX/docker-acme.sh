#!/bin/sh

# CHANGE TO PARENT DIRECTORY
cd "$(dirname "$0")"
cd ..

# MAKE SURE DOMAIN WAS GIVEN
DOMAIN="$1"
if [ "${DOMAIN}" = "" ]; then
	echo "Please pass the domain to generate a cert as the first parameter."
	exit 1
fi

# CREATE DYNU.ENV FILE IF NEEDED
unset Dynu_ClientId
unset Dynu_Secret
test -f "./dynu.env" && . ./dynu.env
if { echo "${Dynu_ClientId}" | grep -E "^(|\*\*\*)$" >/dev/null 2>&1; } || { echo "${Dynu_Secret}" | grep -E "^(|\*\*\*)$" >/dev/null 2>&1; }; then
	printf "Dynu_ClientId=\"***\"\nDynu_Secret=\"***\"\n" >dynu.env
	echo "Please update the dynu.env file"
	exit 1
fi
echo "NOTE: Make sure to delete the 'dynu.env' file after successfully generating a cert."

# GET A CERT
docker run --rm \
	-v "$(pwd)/acme-logs:/var/log/acme-logs" \
	-v "$(pwd)/acme.sh:/acme.sh" \
	--env-file "$(pwd)/dynu.env" \
	neilpang/acme.sh:latest \
		--issue \
		-d ${DOMAIN} \
		-d *.${DOMAIN} \
		--home "/acme.sh" \
		--config-home "/acme.sh/configs" \
		--cert-home "/acme.sh/certs" \
		--server letsencrypt \
		--dns dns_dynu
