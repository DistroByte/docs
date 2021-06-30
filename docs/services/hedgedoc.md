# HedgeDoc

HedgeDoc is running on Hermes in a docker container. It is available [here](https://md.james-hackett.ie).


## Configuration

The docker-compose file is located in `/etc/docker-compose/hedgedoc-container` and looks like this:

```yaml
version: '3'
services:
  database:
    container_name: hedgedoc-database
    image: postgres:9.6-alpine
    environment:
      - POSTGRES_USER=!ENV_USER
      - POSTGRES_PASSWORD=!ENV_PASSWORD
      - POSTGRES_DB=!ENV_DATABASE
    volumes:
      - database:/var/lib/postgresql/data
    networks:
      backend:
    restart: always

  app:
    image: quay.io/hedgedoc/hedgedoc:1.7.2
    environment:
      - CMD_IMAGE_UPLOAD_TYPE=imgur
      - CMD_IMGUR_CLIENTID=!ENV_CLIENTID
      - CMD_ALLOW_FREEURL=true
      - CMD_DEFAULT_PERMISSION=private
      - CMD_DB_URL=postgres://!ENV_USER:!ENV_PASSWORD@database:5432/!ENV_DATABASE
      - CMD_DOMAIN=!ENV_URL
      - CMD_HSTS_PRELOAD=true
      - CMD_USECDN=true
      - CMD_URL_ADDPORT=false
    volumes:
      - uploads:/hedgedoc/public/uploads
    ports:
       - "127.0.0.1:3000:3000"
    networks:
      backend:
    restart: always
    depends_on:
      - database

networks:
  backend:

volumes:
  database:
  uploads:
```

Nginx then reverse proxies port 3000 to `md.james-hackett.ie`. Those configs look like this:

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
before being removed. A notification of the backup is sent to Discord with the time of backup as well as the file size.

The script which cron runs is shown below.

```bash
#!/bin/bash

docker exec hedgedoc-database pg_dump hedgedoc -U hedgedoc > /etc/docker-compose/hedgedoc-container/backups/hedgedoc-$(date +%Y-%m-%d_%H-%M-%S).sql

find /etc/docker-compose/hedgedoc-container/backups/hedgedoc* -ctime +28 -exec rm {} \;

file=$(find /etc/docker-compose/hedgedoc-container/backups/hedgedoc* -ctime -0.24 -exec du -sh {} \; | cut -f1 | xargs | sed 's/.$//')

curl -H "Content-Type: application/json" -d '{"content": "-----------------\n**Hedgedoc Backup**\n-----------------\n`Hedgedoc` has just been backed up!\nFile size: `'"$file"'` megabytes\nDate: `'"$(TZ=Europe/Dublin date)"'`"}' https://canary.discord.com/api/webhooks/$webhook_url
```
