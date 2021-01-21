#!/usr/bin/with-contenv sh

TURN_CONF="${TURN_CONFIG:-/var/run/turn.conf}"
exec turnserver -c "$TURN_CONF" --external-ip="$(/usr/local/bin/detect-external-ip)"