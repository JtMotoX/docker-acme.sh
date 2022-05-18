#!/bin/sh

# CHANGE TO PARENT DIRECTORY
cd "$(dirname "$0")"
cd ..

# SET SOME DEFAULTS
DEFAULT_DNS_PROVIDER="dns_dynu"

# DISPLAY USAGE
usage() {
	cat << EOF 1>&2
---
Usage: $(basename $0)
	-d, --domain	the domain to generate the cert for
	-p, --provider	the dns provider (default: ${DEFAULT_DNS_PROVIDER})
	-h, --help	display this help
EOF
	exit 1;
}

# SHOW USAGE IF NO ARGUMENTS
if [ $# -eq 0 ]; then usage; fi

# GET ARGUMENTS
options=$(getopt -o hd:p: --longoptions help,domain:,provider: -- "$@")
[ $? -eq 0 ] || { 
    echo "Incorrect options provided"
    exit 1
}
eval set -- "$options"
while true; do
	case "$1" in
		-d | --domain)
			DOMAIN="$2"
			shift
			;;
		-p | --provider)
			DNS_PROVIDER="$2"
			shift
			;;
		--help)
			usage
			;;
		--)
			shift
			break
			;;
	esac
	shift
done

# MAKE SURE DOMAIN WAS GIVEN
if [ "${DOMAIN}" = "" ]; then
	echo "ERROR: domain not provided"
	usage
fi

# SET DEFAULT DNS PROVIDER IF NON GIVEN
if [ "${DNS_PROVIDER}" = "" ]; then
	DNS_PROVIDER="${DEFAULT_DNS_PROVIDER}"
fi

# CHECK DYNU VARIABLES IF USING DYNU DNS
if [ "${DNS_PROVIDER}" = "dns_dynu" ]; then
	Dynu_ClientId=$(docker-compose run --rm acme-sh sh -c 'echo "$Dynu_ClientId" | tr -d "\n"')
	if { echo "${Dynu_ClientId}" | grep -E "^(|\*\*\*)$" >/dev/null 2>&1; }; then
		echo "ERROR: You need to provide the 'Dynu_ClientId' in the '.env' file."
		exit 1
	fi
	Dynu_Secret=$(docker-compose run --rm acme-sh sh -c 'echo "$Dynu_Secret" | tr -d "\n"')
	if { echo "${Dynu_Secret}" | grep -E "^(|\*\*\*)$" >/dev/null 2>&1; }; then
		echo "ERROR: You need to provide the 'Dynu_Secret' in the '.env' file."
		exit 1
	fi
fi

# GET A CERT
docker-compose run --rm acme-sh \
	acme.sh \
		--issue \
		-d ${DOMAIN} \
		-d *.${DOMAIN} \
		--dns ${DNS_PROVIDER}
