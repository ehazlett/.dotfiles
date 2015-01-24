#!/bin/bash
if [ -f "/etc/redhat-release" ]; then
    INTERFACE=wlp3s0
    INFO=`/sbin/iwconfig $INTERFACE`
    SSID=`echo $INFO | grep ESSID | cut -d':' -f2 | cut -d'"' -f2`
    SPEED=`echo $INFO | grep "Bit Rate" | cut -d'=' -f2 | cut -d' ' -f1-2`
elif [ -f "/etc/debian_version" ]; then
    INTERFACE=wlan0
    INFO=`/sbin/iwconfig $INTERFACE`
    SSID=`echo $INFO | grep ESSID | cut -d':' -f2 | cut -d'"' -f2`
    SPEED=`echo $INFO | grep "Bit Rate" | cut -d'=' -f2 | cut -d' ' -f1-2`
else
    AIRPORT=/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport
    SSID=`$AIRPORT -I | grep  SSID | tail -1 | cut -d':' -f2 | tr -d " "`
    SPEED=`$AIRPORT -I | grep lastTxRate | cut -d':' -f2 | tr -d " "`
    SPEED="$SPEED mbps"
fi

if [ -z "$SSID" ]; then
    exit 1
fi

echo "$SSID @ $SPEED"
