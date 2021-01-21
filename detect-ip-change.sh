#!/usr/bin/with-contenv sh
CHECK_INTERVAL=${CHECK_INTERVAL:-180}

LAST_IP_FILE=/tmp/last_ip
i=1

while [ "$i" -ne 0 ]
do
  CURRENT_IP="$(/usr/local/bin/detect-external-ip)"

  if [ -f $LAST_IP_FILE ]; then
    while read -r line; do
      if [ ! "$CURRENT_IP" = "$line" ]; then
        echo "IP Change detected, new IP: $CURRENT_IP"
        echo "Restarting TURN"
        killall turnserver
        echo "$CURRENT_IP" > $LAST_IP_FILE
      fi
    done < $LAST_IP_FILE
  else
    echo "$CURRENT_IP" > $LAST_IP_FILE
  fi
  sleep "$CHECK_INTERVAL"
done