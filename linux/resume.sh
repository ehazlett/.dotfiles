#!/bin/bash
LOG=/var/log/resume-vm.log

echo "$(date)" >> $LOG

# resume all vms
case "$1" in
    suspend)
	for vm in $(virsh list --name --state-running); do
	    echo "suspending $vm" >> $LOG
	    virsh suspend $vm
	done
	;;
    resume)
	sleep 10
	for vm in $(virsh list --name --state-paused); do
	    echo "resuming $vm" >> $LOG
	    virsh resume $vm
	done
	;;
esac
