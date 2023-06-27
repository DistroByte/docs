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

# $file - location of the mounted export dir in the paperless container - see
# here: https://github.com/DistroByte/nomad/blob/master/paperless.hcl#L54

docker exec $(docker ps -aqf "name=^paperless-webserver-*") bash document_exporter ../export

file=$(du -sh /data/paperless/export/ | cut -f1 | xargs | sed 's/$//')

if test "$file"; then
  exit 0
else
  curl -H "Content-Type: application/json" -d '{"content": "`Paperless` backup has just **FAILED**\nFile size: `'"$file"'`\nDate: `'"$(TZ=Europe/Dublin date)"'`"}' https://canary.discord.com/api/webhooks/$webhook_url
```
