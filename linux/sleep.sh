#!/bin/bash
i3lock -c 000000 -e &
sleep 1

# pause all vms
for vm in $(virsh list --name --state-running); do
    echo "suspending $vm"
    virsh suspend $vm
done

sudo pm-suspend
