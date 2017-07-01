#!/bin/bash
DOCKER_VERSION=${DOCKER_VERSION:-"17.06.0"}
DOCKER_DATA_DIR=${DOCKER_DATA_DIR:-"$HOME/.docker"}
DIND_NETWORK_NAME=${DIND_NETWORK_NAME:-"dind"}

function launch-node() {
    if [ -z "$1" ]; then
        echo "Usage: 0 <node>"
    fi
    NODE=$1
    docker network create ${DIND_NETWORK_NAME}
    docker run \
        --privileged \
        --net ${DIND_NETWORK_NAME} \
        --name ${NODE} \
        --hostname ${NODE} \
        -v ${DOCKER_DATA_DIR}-${NODE}:/var/lib/docker \
        --tmpfs /run \
        -v /lib/modules:/lib/modules:ro \
        -d \
        ehazlett/dind:${DOCKER_VERSION} -H unix://
}
