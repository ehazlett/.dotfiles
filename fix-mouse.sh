#!/bin/bash
MOUSEHANDLE=`hcitool con  | grep "E3:9A:00:86:A8:CA" | awk '{print $5}'`
hcitool lecup --handle $MOUSEHANDLE --min 6 --max 7 --latency 0
