#!/bin/bash
DOCKER_VERSION=${DOCKER_VERSION:-"17.06.0-ce"}
DOCKER_VOLUME_PREFIX=${DOCKER_VOLUME_PREFIX:-"docker"}
NETWORK_NAME=${NETWORK_NAME:-"local"}
UCP_VERSION=${UCP_VERSION:-"latest"}
UCP_ADMIN_USER=${UCP_ADMIN_USER:-"admin"}
UCP_ADMIN_PASS=${UCP_ADMIN_PASS:-"dockerucp123"}
DOCKER_ARGS=${DOCKER_ARGS:-}

function launch-nodes() {
    if [ -z "$1" ]; then
        echo "Usage: launch-nodes <node> [node]"
        return
    fi
    NODES="$@"
    for NODE in ${NODES}; do
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
            ehazlett/docker:${DOCKER_VERSION} -H unix:// -s overlay2 ${DOCKER_ARGS}
    done
}

function install-ucp() {
    NODE=$1
    docker exec -ti ${NODE} docker run --rm -it --name ucp \
          -v /var/run/docker.sock:/var/run/docker.sock \
            docker/ucp:${UCP_VERSION} install \
                -D --admin-username ${UCP_ADMIN_USER} \
                --admin-password ${UCP_ADMIN_PASS} \
                --san ucp.local \
                --disable-tracking \
                --disable-usage
}

function remove-nodes() {
    if [ -z "$1" ]; then
        echo "Usage: remove-nodes <node> [node]"
        return
    fi
    NODES="$@"
    for NODE in ${NODES}; do
        docker rm -fv ${NODE}
        docker volume rm -f ${DOCKER_VOLUME_PREFIX}-${NODE}
    done
}
