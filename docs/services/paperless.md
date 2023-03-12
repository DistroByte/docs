# Paperless-ngx

Paperless-ngx is a place where scanned documents like bills and statements can be stored to reduce the amount of paper
in use. It can automatically tag a new document when it arrives and provides OCR on the document to allow it to be searched
easily.

It is available [here](https://paperless.dbyte.xyz).

## Configuration

Running on nomad, the job file is located at [`paperless.hcl`](https://github.com/DistroByte/nomad/blob/master/paperless.hcl).

## Backup Strategy

Paperless is backed up once a week to `/volume1/backups/paperless` on Dionysus. The way Paperless-ng handles
exporting documents allows incremental backups, this is how it is implemented here. It runs once a week.

This script execs into the paperless webserver and runs the `document_exporter` command. This exports all the info
to ../export which is mounted on the file system. The `$file` variable contains the size of the export. The data is then
copied into the mounted folder and a notification to Discord is sent.

```bash
#!/bin/bash

docker exec paperless_webserver_1 bash document_exporter ../export

file=$(du -sh /etc/docker-compose/paperless-ng/export/ | cut -f1 | xargs |
sed 's/$//')

cp -R /etc/docker-compose/paperless-ng/export/ /etc/docker-compose/paperless-ng
/backup

curl -H "Content-Type: application/json" -d '{"content": "-----------------\n**
Paperless Backup**\n-----------------\n`Paperless` has just been backed up!\nFile
size: `'"$file"'`\nDate: `'"$(TZ=Europe/Dublin date)"'`"}'
https://canary.discord.com/api/webhooks/$webhook_url
```
