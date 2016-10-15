#!/bin/bash
# this script will resume all paused vms upon a system resume
# this script should be placed in /etc/pm/sleep.d

# resume all vms
case "${1}" in
    resume|thaw)
	for vm in $(virsh list --name --state-paused); do
	    echo "resuming $vm"
	    virsh resume $vm
	done
;;
esac
