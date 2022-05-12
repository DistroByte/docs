# Paperless-ng

Paperless-ng is running on Hermes in a docker container. Paperless-ng is
a place where scanned documents like bills and statements can be stored to reduce the amount of paper in use. It can
automatically tag a new document when it arrives and provides OCR on the document to allow it to be searched easily.
It is available [here](https://paperless.dbyte.xyz).

Paperless-ng is a variation on the original [paperless](https://github.com/the-paperless-project/paperless) project,
which was archived. The container and its dependencies are installed with a
[script from the documentation](https://paperless-ng.readthedocs.io/en/latest/setup.html#setup-docker-script). This
script is located at `/etc/docker-compose/install-paperless-ng.sh`.

The repo for Paperless-ng is [here](https://github.com/jonaswinkler/paperless-ng).

## Configuration

Beyond the install script, there is very little base configuration to do. Most of the important info is stored in the
database directly. This is then backed up to Dionysus.

The `docker-compose.yml` file looks like this:

```yaml
version: "3.4"
services:
  broker:
    image: redis:6.0
    restart: unless-stopped

  db:
    image: postgres:13
    restart: unless-stopped
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: !ENV_DB
      POSTGRES_USER: !ENV_USER
      POSTGRES_PASSWORD: !ENV_PASSWORD

  webserver:
    image: jonaswinkler/paperless-ng:latest
    restart: unless-stopped
    depends_on:
      - db
      - broker
    ports:
      - 8000:8000
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000"]
      interval: 30s
      timeout: 10s
      retries: 5
    volumes:
      - /etc/docker-compose/paperless-ng/data:/usr/src/paperless/data
      - /etc/docker-compose/paperless-ng/media:/usr/src/paperless/media
      - ./export:/usr/src/paperless/export
      - /etc/docker-compose/paperless-ng/consume:/usr/src/paperless/consume
    env_file: docker-compose.env
    environment:
      PAPERLESS_REDIS: redis://broker:6379
      PAPERLESS_DBHOST: db


volumes:
  data:
  media:
  pgdata:
```

Nginx reverse proxies `paperless.dbyte.xyz` to port `8000`, this is the config for it.

```nginx
map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
}
server {
    server_name paperless.james-hackett.ie;
    listen 80;
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /socket.io/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
    }

    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/james-hackett.ie/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/james-hackett.ie/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

}
```

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
