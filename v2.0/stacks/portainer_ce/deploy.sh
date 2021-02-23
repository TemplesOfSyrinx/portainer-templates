#!/usr/bin/env bash

set -eu
# set -x

: ${1?"Usage: $0 <ACTION> [<PORTAINER_PUBLISHED_PORT> [<PORTAINER_PORT> [<AGENT_PUBLISHED_PORT> [<AGENT_PORT> [<AGENT_HOST> [<AGENT_SECRET> [<TZ>]]]]]]]"}
ACTION=$1 # up, down

# Construct a string of environemnt variables if we need it
ENV_VARIABLES=

# Portainer deployment options:
PORT=9000

# Agent deployment options:
DEFAULT_PORT=9001

# Portainer Published Port
# If PORTAINER_PUBLISHED_PORT is unset (does not exist in the environment) or is empty, expect it as the second parameter and export.
# If no second parameter, set to default
export PORTAINER_PUBLISHED_PORT=${PORTAINER_PUBLISHED_PORT:-${2:-${PORT}}}
# TODO: check that it is within a valid port range
ENV_VARIABLES="${ENV_VARIABLES} -e PORTAINER_PUBLISHED_PORT=${PORTAINER_PUBLISHED_PORT}"
# Show variable in the environment
env | grep PORTAINER_PUBLISHED_PORT

# Portainer Port
# If PORTAINER_PORT is unset (does not exist in the environment) or is empty, expect it as the second parameter and export.
# If no third parameter, set to default
export PORTAINER_PORT=${PORTAINER_PORT:-${3:-${PORT}}}
# TODO: check that it is within a valid port range
ENV_VARIABLES="${ENV_VARIABLES} -e PORTAINER_PORT=${PORTAINER_PORT}"
# Show variable in the environment
env | grep PORTAINER_PORT

# Agent Published Port
# If AGENT_PUBLISHED_PORT is unset (does not exist in the environment) or is empty, expect it as the second parameter and export.
# If no fourth parameter, set to default
export AGENT_PUBLISHED_PORT=${AGENT_PUBLISHED_PORT:-${4:-${DEFAULT_PORT}}}
# TODO: check that it is within a valid port range
ENV_VARIABLES="${ENV_VARIABLES} -e AGENT_PUBLISHED_PORT=${AGENT_PUBLISHED_PORT}"
# Show variable in the environment
env | grep AGENT_PUBLISHED_PORT

# Agent Port
# If AGENT_PORT is unset (does not exist in the environment) or is empty, expect it as the third parameter and export.
# If no fifth parameter, set to default
export AGENT_PORT=${AGENT_PORT:-${5:-${DEFAULT_PORT}}}
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
    # Check for AGENT_HOST as sixth parameter
    if [ -z "${6+set}" ]; then
       1>&2 echo "AGENT_HOST (parameter 6) is unset"
    elif [ -z "${6-unset}" ]; then
       # AGENT_HOST (6) set but empty, don't pass an empty value to container
       1>&2 echo "AGENT_HOST (parameter 6) empty"
    else 
       export AGENT_HOST=${6}
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
    # Check for AGENT_SECRET as seventh parameter
    if [ -z "${7+set}" ]; then
       1>&2 echo "AGENT_SECRET (parameter 7) is unset"
    elif [ -z "${7-unset}" ]; then
       # AGENT_SECRET (7) set but empty, don't pass an empty value to container
       1>&2 echo "AGENT_SECRET (parameter 7) empty"
    else 
       export AGENT_SECRET=${7}
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
    # Check for TZ as eigth parameter
    if [ -z "${8+set}" ]; then
       1>&2 echo "TZ (parameter 8) is unset"
    elif [ -z "${8-unset}" ]; then
       # TZ (6) set but empty, don't pass an empty value to container
       1>&2 echo "TZ (parameter 8) empty"
    else 
       export TZ=${8}
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
