# Unifi-Controller

Unifi-Controller is running in docker on Hermes and acts as the interface to interact with Hades. It is available to
access from inside the network on port `8443` on Hermes, or from [this link](https://192.168.1.3:8443/).

This container is built from the [linuxserver/unifi-controller](https://hub.docker.com/r/linuxserver/unifi-controller) image.

## Configuration

The docker-compose file for this container is located at `/etc/docker-compose/unifi` on Hermes.

```yaml
version: "2.1"

services:
  unifi-controller:
    image: ghcr.io/linuxserver/unifi-controller
    container_name: unifi
    environment:
      - PUID=1000
      - PGID=1000
    volumes:
      - /etc/docker-compose/unifi/config:/config
    ports:
      - 3478:3478/udp
      - 10001:10001/udp
      - 8080:8080/tcp
      - 8443:8443/tcp
    restart: unless-stopped
```

The actual config for the controller is located in the same directory as the compose file.

## Backup Strategy

The Unifi Controller container has a function to auto backup its configs at set intervals. These backups are stored in `/etc/docker-compose/unifi/config/data/backup/autobackup`.
The controller backs up its config every week (Monday at 1am UTC) and retains the configs for 28 days.

The backup files are then synced with `/volume1/backups/unifi` on Dionysus with a cron job that runs every day.

Cron calls this script when it runs:

```bash
#!/bin/bash

file=$(find /etc/docker-compose/unifi/config/data/backup/autobackup/* -type f 
-ctime -1 | grep ".*\.unf$")

if test -f "$file"; then
    cp $file /etc/docker-compose/unifi/backup/

    find /etc/docker-compose/unifi/backup/autobackup* -ctime +28 -exec rm {} \;

    filesize=$(du -sh $file | cut -f1 | xargs | sed 's/$//')

    curl -H "Content-Type: application/json" -d '{"content": "-----------------\n
    **Unifi Backup**\n-----------------\n`Unifi` has just been backed up!\nFile 
    size: `'"$filesize"'`\nDate: `'"$(TZ=Europe/Dublin date)"'`"}' 
    https://canary.discord.com/api/webhooks/$webhook_url
fi
```
