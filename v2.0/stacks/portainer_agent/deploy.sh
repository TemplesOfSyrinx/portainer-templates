#!/usr/bin/env bash

set -eu
# set -x

: ${1?"Usage: $0 <ACTION> [<AGENT_PUBLISHED_PORT> [<AGENT_PORT> [<AGENT_HOST> [<AGENT_SECRET> [<TZ>]]]]]"}
ACTION=$1 # up, down

# Construct a string of environemnt variables if we need it
ENV_VARIABLES=

# Agent deployment options:
DEFAULT_PORT=9001

# Agent Published Port
# If AGENT_PUBLISHED_PORT is unset (does not exist in the environment) or is empty, expect it as the second parameter and export.
# If no second parameter, set to default
export AGENT_PUBLISHED_PORT=${AGENT_PUBLISHED_PORT:-${2:-${DEFAULT_PORT}}}
# TODO: check that it is within a valid port range
ENV_VARIABLES="${ENV_VARIABLES} -e AGENT_PUBLISHED_PORT=${AGENT_PUBLISHED_PORT}"
# Show variable in the environment
env | grep AGENT_PUBLISHED_PORT

# Agent Port
# If AGENT_PORT is unset (does not exist in the environment) or is empty, expect it as the third parameter and export.
# If no third parameter, set to default
export AGENT_PORT=${AGENT_PORT:-${3:-${DEFAULT_PORT}}}
# TODO: check that it is within a valid port range
ENV_VARIABLES="${ENV_VARIABLES} -e AGENT_PORT=${AGENT_PORT}"
# Show variable in the environment
env | grep AGENT_PORT

if [ "$ACTION" = "up" ]
then
    # Agent Host
    # If AGENT_HOST is unset (does not exist in the environment).
    if [ -z "${AGENT_HOST+set}" ]; then
       1>&2 echo "AGENT_HOST is unset"
    elif [ -z "${AGENT_HOST-unset}" ]; then
       # AGENT_HOST set but empty, don't pass an empty value to container
       1>&2 echo "AGENT_HOST empty, unsetting"
       unset AGENT_HOST
    fi
    # Check for AGENT_HOST as fourth parameter
    if [ -z "${4+set}" ]; then
       1>&2 echo "AGENT_HOST (parameter 4) is unset"
    elif [ -z "${4-unset}" ]; then
       # AGENT_HOST (4) set but empty, don't pass an empty value to container
       1>&2 echo "AGENT_HOST (parameter 4) empty"
    else 
       export AGENT_HOST=${4}
       # TODO: check that it is within a valid host range
       # Show variable in the environment
       env | grep AGENT_HOST
    fi
    if [ ! -z "${AGENT_HOST+set}" ]; then
       ENV_VARIABLES="${ENV_VARIABLES} -e AGENT_HOST=${AGENT_HOST}"
    fi
    
    # Agent Secret
    # If AGENT_SECRET is unset (does not exist in the environment).
    if [ -z "${AGENT_SECRET+set}" ]; then
       1>&2 echo "AGENT_SECRET is unset"
    elif [ -z "${AGENT_SECRET-unset}" ]; then
       # AGENT_SECRET set but empty, don't pass an empty value to container
       1>&2 echo "AGENT_SECRET empty, unsetting"
       unset AGENT_SECRET
    fi
    # Check for AGENT_SECRET as fifth parameter
    if [ -z "${5+set}" ]; then
       1>&2 echo "AGENT_SECRET (parameter 5) is unset"
    elif [ -z "${5-unset}" ]; then
       # AGENT_SECRET (5) set but empty, don't pass an empty value to container
       1>&2 echo "AGENT_SECRET (parameter 5) empty"
    else 
       export AGENT_SECRET=${5}
       # Show variable in the environment
       env | grep AGENT_SECRET
    fi
    if [ ! -z "${AGENT_SECRET+set}" ]; then
       ENV_VARIABLES="${ENV_VARIABLES} -e AGENT_SECRET=${AGENT_SECRET}"
    fi
    
    # Timezone
    # If TZ is unset (does not exist in the environment).
    if [ -z "${TZ+set}" ]; then
       1>&2 echo "TZ is unset"
    elif [ -z "${TZ-unset}" ]; then
       # TZ set but empty, don't pass an empty value to container
       1>&2 echo "TZ empty, unsetting"
       unset TZ
    fi
    # Check for TZ as sixth parameter
    if [ -z "${6+set}" ]; then
       1>&2 echo "TZ (parameter 6) is unset"
    elif [ -z "${6-unset}" ]; then
       # TZ (6) set but empty, don't pass an empty value to container
       1>&2 echo "TZ (parameter 6) empty"
    else 
       export TZ=${6}
       # TODO: check that it is within a valid timezone
       # Show variable in the environment
       env | grep TZ
    fi
    if [ ! -z "${TZ+set}" ]; then
       ENV_VARIABLES="${ENV_VARIABLES} -e TZ=${TZ}"
    fi

    if type docker-compose >/dev/null 2>&1; then
       # if docker-compose is installed, most likely docker is also
       docker-compose -p portainer ${ACTION} -d
    else
       echo >&2 "Script expecting docker-compose but it's not installed.  Using docker/compose container instead."
       type docker >/dev/null 2>&1 || { echo >&2 "Script requires docker but it's not installed.  Aborting."; exit 1; }
       docker run -ti --rm \
       -v $(pwd):$(pwd) -v /var/run/docker.sock:/var/run/docker.sock -w $(pwd) \
       ${ENV_VARIABLES} \
       docker/compose -p portainer ${ACTION} -d    
    fi
elif [ "$ACTION" = "down" ]
then
    if type docker-compose >/dev/null 2>&1; then
       # if docker-compose is installed, most likely docker is also
       docker-compose -p portainer ${ACTION}
    else
       echo >&2 "Script expecting docker-compose but it's not installed.  Using docker/compose container instead."
       type docker >/dev/null 2>&1 || { echo >&2 "Script requires docker but it's not installed.  Aborting."; exit 1; }
       docker run -ti --rm \
       -v $(pwd):$(pwd) -v /var/run/docker.sock:/var/run/docker.sock -w $(pwd) \
       ${ENV_VARIABLES} \
       docker/compose -p portainer ${ACTION}    
    fi
else
    1>&2 echo "Invalid action. Must be up or down"
fi
