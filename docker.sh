#!/bin/bash
DOCKER_VERSION=${DOCKER_VERSION:-"17.06.0-ce"}
DOCKER_VOLUME_PREFIX=${DOCKER_VOLUME_PREFIX:-"docker"}
NETWORK_NAME=${NETWORK_NAME:-"local"}

function launch-node() {
    if [ -z "$1" ]; then
        echo "Usage: 0 <node>"
        exit 1
    fi
    NODE=$1
    VOL_NAME=${DOCKER_VOLUME_PREFIX}-${NODE}
    docker network create ${NETWORK_NAME} > /dev/null 2>&1
    docker volume create -d local ${VOL_NAME} > /dev/null 2>&1
    docker run \
        --privileged \
        --net ${NETWORK_NAME} \
        --name ${NODE} \
        --hostname ${NODE} \
        --tmpfs /run \
        -v /lib/modules:/lib/modules:ro \
        -v ${VOL_NAME}:/var/lib/docker \
        -d \
        ehazlett/docker:${DOCKER_VERSION} -H unix:// -s overlay2
}
