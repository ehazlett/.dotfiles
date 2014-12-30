#!/bin/bash
AIRPORT=/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport
SSID=`$AIRPORT -I | grep  SSID | tail -1 | cut -d':' -f2 | tr -d " "`
SPEED=`$AIRPORT -I | grep lastTxRate | cut -d':' -f2 | tr -d " "`

if [ -z "$SSID" ]; then
    exit 1
fi

echo "W: $SSID @ $SPEED mbps"
