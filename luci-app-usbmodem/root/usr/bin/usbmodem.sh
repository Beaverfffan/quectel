#!/bin/sh
# leovs @2023.6.2

device=$(uci get usbmodem.@service[0].readport)
pidfile=/var/run/usbmodem.pid

status() {
  if ! test -e $pidfile; then
    touch $pidfile
    echo '' > /tmp/usbmodem_status.log
    gcom -d "$device" -s "/lib/usbmodem/usbmodem_status.gcom" >> /tmp/usbmodem_status.log
    rm -f $pidfile
  fi
}

case "$1" in
status)
  status
  ;;
done) ;;
esac
