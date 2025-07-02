#!/bin/bash
if [[ ! -d /var/lib/clamav ]]; then
  mkdir -p /var/lib/clamav
  chown clamav:clamav /var/lib/clamav
fi

if [[ ! -f /home/clamav/fangfrisch.conf ]]; then
  fangfrisch dumpconf|sed 's|\[DEFAULT\]|\[DEFAULT\]\ndb_url = sqlite:////home/clamav/db.sqlite\nlocal_directory = /var/lib/clamav|; s|enabled.*|enabled = true|; s|\[securiteinfo\]|\[securiteinfo\]\nenabled = false| ; s|\[malwarepatrol\]|\[malwarepatrol\]\nenabled = false|' > /home/clamav/fangfrisch.conf
fi

if [[ ! -f /home/clamav/db.sqlite ]]; then
  fangfrisch --conf /home/clamav/fangfrisch.conf initdb
fi

exec "$@"

while true; do
  echo "⏰ UPDATING virus definitions: $(date)"
  fangfrisch --conf /home/clamav/fangfrisch.conf refresh
  sleep 600
done

