#!/bin/bash
INTERFACE=wlp3s0
if [ -f "/etc/redhat-release" ]; then
    INFO=`/sbin/iwconfig $INTERFACE`
    SSID=`echo $INFO | grep ESSID | cut -d':' -f2 | cut -d'"' -f2`
else
    AIRPORT=/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport
    SSID=`$AIRPORT -I | grep  SSID | tail -1 | cut -d':' -f2 | tr -d " "`
    SPEED=`$AIRPORT -I | grep lastTxRate | cut -d':' -f2 | tr -d " "`
fi

echo $SSID

if [ -z "$SSID" ]; then
    exit 1
fi

echo "W: $SSID @ $SPEED mbps"
