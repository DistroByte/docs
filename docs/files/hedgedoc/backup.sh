#!/bin/bash

base=/etc/docker-compose/hedgedoc-container/backups/hedgedoc
file=$base-$(date +%Y-%m-%d_%H-%M-%S).sql

docker exec hedgedoc-database pg_dump hedgedoc -U hedgedoc > "${file}"

find $base* -ctime +14 -exec rm {} \;

if test -f "$file"; then
  exit 0
else
  curl -H "Content-Type: application/json" -d '{"content": "`HedgeDoc` backup has just **FAILED**\nFile name: `'"$file"'`\nDate: `'"$(TZ=Europe/Dublin date)"'`"}'  https://canary.discord.com/api/webhooks/$webhook_url
fi