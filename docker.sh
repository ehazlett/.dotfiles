#!/bin/bash
#
# Helper Docker Functions

# load in helpers from jess
source dockerfunc

lastpass() {
    echo $@
    docker run -ti --rm \
        -v $HOME/Sync/home/config/lastpass:/root/.lpass \
        --log-driver none \
        --entrypoint /bin/bash \
        ehazlett/lastpass-cli -l
}
