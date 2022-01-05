# HedgeDoc

HedgeDoc is running on Hermes in a docker container. HedgeDoc is a web editor for markdown notes and contains everything
from college notes to personal journal entries and todo lists.

It's available [here](https://md.james-hackett.ie).

The repository which the container is from is located on the [hedgedoc/container](https://github.com/hedgedoc/container)
repo.

## Configuration

=== "Docker Compose"

    The docker-compose file is located in `/etc/docker-compose/hedgedoc-container`.

    Traefik reverse proxies port 3000 to `md.james-hackett.ie`.

    Download file from [here](../files/hedgedoc/docker-compose.yml)

    ```yaml
    version: '3'
    services:
    database:
        container_name: hedgedoc-database
        image: postgres:9.6-alpine
        environment:
        - POSTGRES_USER=hedgedoc
        - POSTGRES_PASSWORD=password
        - POSTGRES_DB=hedgedoc
        volumes:
        - database:/var/lib/postgresql/data
        networks:
        backend:
        restart: always

    app:
        container_name: hedgedoc-frontend
        image: quay.io/hedgedoc/hedgedoc:1.7.2
        environment:
        - CMD_IMAGE_UPLOAD_TYPE=imgur
        - CMD_IMGUR_CLIENTID=fe790a1b5b9f642
        - CMD_ALLOW_FREEURL=true
        - CMD_DEFAULT_PERMISSION=private
        - CMD_DB_URL=postgres://hedgedoc:password@database:5432/hedgedoc
        - CMD_DOMAIN=md.james-hackett.ie
        - CMD_HSTS_PRELOAD=true
        - CMD_USECDN=true
        - CMD_PROTOCOL_USESSL=true
        - CMD_URL_ADDPORT=false
        volumes:
        - uploads:/hedgedoc/public/uploads
        ports:
        - "127.0.0.1:3000:3000"
        labels:
        - "traefik.frontend.headers.STSSeconds=63072000"
        - "traefik.frontend.headers.browserXSSFilter=true"
        - "traefik.frontend.headers.contentTypeNosniff=true"
        - "traefik.frontend.headers.customResponseHeaders=alt-svc:
            h2=l3sb47bzhpbelafss42pspxzqo3tipuk6bg7nnbacxdfbz7ao6semtyd.onion:443;
            ma=2592000"
        - "traefik.enable=true"
        - "traefik.port=3000"
        - "traefik.docker.network=traefik_web"
        - "traefik.http.routers.md.rule=Host(`md.james-hackett.ie`)"
        - "traefik.http.routers.md.tls=true"
        - "traefik.http.routers.md.tls.certresolver=lets-encrypt"
        networks:
        - backend
        - traefik_web
        restart: always
        depends_on:
        - database

    networks:
    traefik_web:
        external: true
    backend:
        external: false

    volumes:
    database:
    uploads:
    ```

=== "Nginx"

    Nginx was used to proxy traffic to the contianer, however I moved to
    traefik to take advantage of the automatic SSL cert generation.

    Download file from [here](../files/hedgedoc/hedgedoc-nginx.conf)

    ```nginx
    map $http_upgrade $connection_upgrade {
            default upgrade;
            ''      close;
    }

    server {
            server_name md.james-hackett.ie;

            location / {
                    proxy_pass http://127.0.0.1:3000;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;
            }

            location /socket.io/ {
                    proxy_pass http://127.0.0.1:3000;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;
                    proxy_set_header Connection $connection_upgrade;
            }

            #listen 443 ssl http2;
            #ssl_certificate /var/cloudflare/cert.pem;
            #ssl_certificate_key /var/cloudflare/key.pem;
    }
    ```

## Backup Strategy

HedgeDoc is backed up every 6 hours to `/volume1/backups/hedgedoc/` on Dionysus. The files are then kept for 28 days
before being removed. If the backup fails, a ping is sent to a Discord channel with the filename and date of the backup.

The script which `cron` runs is shown below. It execs into the hedgedoc-database container and runs `pg_dump`. This is
then sent to the mounted backup folder. The script then removes files older than 14 days and gets the file size of the most
recent backup. Finally a notification is sent to Discord if the backup fails, otherwise, the script exits cleanly.

Download file from [here](../files/hedgedoc/backup.sh).

```bash
#!/bin/bash

base=/etc/docker-compose/hedgedoc-container/backups/hedgedoc
file=$base-$(date +%Y-%m-%d_%H-%M-%S).sql

docker exec hedgedoc-database pg_dump hedgedoc -U hedgedoc > "${file}"

find $base* -ctime +14 -exec rm {} \;

if test -f "$file"; then
  exit 0
else
  curl -H "Content-Type: application/json" -d '{"content": "`HedgeDoc` backup has
  just **FAILED**\nFile name: `'"$file"'`\nDate: `'"$(TZ=Europe/Dublin date)"'`"}'
  https://canary.discord.com/api/webhooks/$webhook_url
fi
```
