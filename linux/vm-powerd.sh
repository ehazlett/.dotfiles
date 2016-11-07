#!/bin/bash
LOG=/var/log/resume-vm.log

echo "$(date)" >> $LOG
echo "$1" >> $LOG

# resume all vms
case "$1" in
    suspend)
	for vm in $(virsh list --name --state-running); do
	    echo "saving $vm" >> $LOG
	    virsh managedsave $vm
	done
	;;
    resume)
	sleep 3
	for vm in $(virsh list --name --state-shutoff --with-managed-save); do
	    echo "resuming $vm" >> $LOG
	    virsh start $vm
	done
	;;
esac
