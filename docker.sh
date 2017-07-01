#!/bin/bash
DOCKER_VERSION=${DOCKER_VERSION:-"17.06.0"}

function launch-node() {
    if [ -z "$1" ]; then
        echo "Usage: 0 <node>"
    fi
    NODE=$1
    docker run \
        --privileged \
        --net dind \
        --name ${NODE} \
        --hostname ${NODE} \
        -v /var/tmp/docker-${NODE}:/var/lib/docker \
        --tmpfs /run \
        -v /lib/modules:/lib/modules:ro \
        -d \
        ehazlett/dind:17.06.0 -H unix://
}
