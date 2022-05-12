# Media Stack

I run quite a large stack for downloading, indexing and watching media over the internt. All of these
services run on Dionysus. The stack includes:

- [ruTorrent](#rutorrent)
- [OpenVPN](#openvpn)
- [Sonarr/Radarr](#sonarrradarr)
- [Overseerr](#overseerr)
- [Jackett](#jackett)
- [Plex](#plex)
- [Tautulli](#tautulli)

These services all contribute to allow me to watch TV shows and movies very easily wherever I am in the world.

They are all managed by one large `docker-compose.yml` file, but I will go through each service individually.

The flow chart from adding a movie to watching it looks like this:

![flowchart](https://i.dbyte.xyz/2021-07-Gf.svg)

## General Configuration

These services are all located in `/etc/docker-compose/plex` on Dionysus, and thus are quite easy to configure all together
using environment variables. The config for each service is located in `${ROOT}/config/$service_name` and any other directory
the service needs is created before starting the containers.

### Note

I won't dive into each individual service's configuration, that will be done on their respective pages. This will just
contain the basics of how to get the service running.

## ruTorrent

ruToorent is a torrenting client with some nice features over other torrenting clients of similar standing. I'm
using the container from [linuxserver/rutorrent](https://hub.docker.com/r/linuxserver/rutorrent). There is a compose
file on that page, but I had to adapt mine slightly to make use of the VPN I wanted to use.

### Configuration

The `docker-compose.yml` file is quite sparse, but it does not have to be complicated.

```yml
rutorrent:
  image: linuxserver/rutorrent
  container_name: rutorrent
  network_mode: service:vpn
  environment:
    - PUID=${PUID}
    - PGID=${PGID}
  volumes:
    - ${ROOT}/config/rutorrent:/config
    - ${ROOT}/downloads:/downloads
  restart: always
```

**NOTE** This is just a snippet of the whole file, see below for the entire file.

### Points to Note

The container will not start unless the VPN has also started, thus it is one of the last services to come up when
`docker-compose up -d` is run.

### Backups

This config is backed up by default as it exists on Dionysus, however, I plan to make offsite backups and this
configuration would be included in it.

## OpenVPN

OpenVPN is what allows my torrenting to be anonymous (whoops, let that one slip). I have it configured to point to the Netherlands
with [PrivateInternetAccess](privateinternetaccess.com/). I have had no issues with them, and I have it installed on all
my devices too. OpenVPN uses the [dperson/openvpn-client](https://github.com/dperson/openvpn-client) container.

### Configuration

The `docker-compose.yml` file is quite sparse here, but it does not have to be complicated.

```yml
vpn:
  container_name: vpn
  image: dperson/openvpn-client
  cap_add:
    - net_admin
  restart: always
  volumes:
    - /dev/net:/dev/net:z
    - ${ROOT}/config/vpn:/vpn
  security_opt:
    - label:disable
  ports:
    - 8111:80
    - 9117:9117
  command: '-f "" -r 192.168.1.0/24'
```

**NOTE** This is just a snippet of the whole file, see below for the entire file.

Because I am running this on a Synology, OpenVPN has some issues creating a tunnel. I had to create a file to open the tunnel
whenever the machine restarted. It's a simple bash script that Synology runs on startup.

```bash
#!/bin/sh

# Create the necessary file structure for /dev/net/tun
if ( [ ! -c /dev/net/tun ] ); then
  if ( [ ! -d /dev/net ] ); then
    mkdir -m 755 /dev/net
  fi
  mknod /dev/net/tun c 10 200
fi

# Load the tun module if not already loaded
if ( !(lsmod | grep -q "^tun\s") ); then
  insmod /lib/modules/tun.ko
fi
```

There are some config files that the VPN needs. They are placed in `config/vpn`. These files are:

- `vpn.auth`
- `vpn.conf`
- `ca.rsa.2048.crt`
- `crl.rsa.2048.pem`

### Backup

This config is backed up by default as it exists on Dionysus, however, I plan to make offsite backups and this
configuration would be included in it.

## Sonarr/Radarr

Sonarr and Radarr provide a well designed interface to interact with the data from torrent indexers, like Jackett. They
interact with both the download client (deluge) and the indexer (jackett) to make it as simple as possible to get the
correct quality and release.

### Configuration

The `docker-compose.yml` file is quite sparse here, but it does not have to be complicated.

```yml
sonarr:
  container_name: sonarr
  image: linuxserver/sonarr
  restart: always
  network_mode: host
  environment:
    - PUID=${PUID}
    - PGID=${PGID}
    - TZ=${TIMEZONE}
  volumes:
    - /etc/localtime:/etc/localtime:ro
    - ${ROOT}/config/sonarr:/config
    - /volume1/media/tv:/tv
    - ${ROOT}/downloads:/downloads

radarr:
  container_name: radarr
  image: linuxserver/radarr
  restart: always
  network_mode: host
  environment:
    - PUID=${PUID}
    - PGID=${PGID}
    - TZ=${TIMEZONE}
  volumes:
    - /etc/localtime:/etc/localtime:ro
    - ${ROOT}/config/radarr:/config
    - ${ROOT}/downloads:/downloads
    - /volume1/media/movies:/movies
```

**NOTE** This is just a snippet of the whole file, see below for the entire file.

### Backup

This config is backed up by default as it exists on Dionysus, however, I plan to make offsite backups and this
configuration would be included in it.

## Overseerr

Overseerr is very similar to both Sonarr and Radarr, but it interacts with both at once to just have one streamlined
interface for both movies and tv shows. This acts in a similar way to Sonarr/Radarr asking Jackett for torrents,
but you can set limits for users on it. It is also compatible with both desktop and mobile.

### Configuration

The `docker-compose.yml` file is quite sparse here, but it does not have to be complicated.

```yml
overseerr:
  container_name: overseerr
  image: linuxserver/overseerr
  restart: unless-stopped
  ports:
    - 5055:5055
  environment:
    - TZ=${TIMEZONE}
  volumes:
    - ${ROOT}/config/overseerr:/app/config
```

**NOTE** This is just a snippet of the whole file, see below for the entire file.

### Backup

This config is backed up by default as it exists on Dionysus, however, I plan to make offsite backups and this
configuration would be included in it.

## Jackett

Jackett is a torrent indexer. It grabs the torrent links from specified websites and provides them (over an api)
to Sonarr and Radarr. It is a very powerful piece of software and is the key to the entire media stack.

### Configuration

The `docker-compose.yml` file is quite sparse here, but it does not have to be complicated.

```yml
jackett:
  container_name: jackett
  image: linuxserver/jackett
  restart: always
  network_mode: service:vpn
  environment:
    - PUID=${PUID}
    - PGID=${PGID}
    - TZ=${TIMEZONE}
  volumes:
    - /etc/localtime:/etc/localtime:ro
    - ${ROOT}/downloads/blackhole:/downloads
    - ${ROOT}/config/jackett:/config
```

**NOTE** This is just a snippet of the whole file, see below for the entire file.

### Backup

This config is backed up by default as it exists on Dionysus, however, I plan to make offsite backups and this
configuration would be included in it.

## Plex

Plex is the app that allows me to view my media. It is an extremely powerful media center with auto searching of
folders, auto grabbing of posters, transcoding built in, ability to sign in with a Google account and so much more.
Plex is available to me anywhere in the world on both the web and the mobile app.

### Configuration

The `docker-compose.yml` file is quite sparse here, but it does not have to be complicated.

```yml
plex:
  container_name: plex
  image: plexinc/pms-docker
  restart: unless-stopped
  network_mode: host
  environment:
    - TZ=${TIMEZONE}
    - PLEX_CLAIM=${PLEX_CLAIM}
  volumes:
    - ${ROOT}/config/plex/db:/config
    - ${ROOT}/config/plex/transcode:/transcode
    - /volume1/media:/data
```

**NOTE** This is just a snippet of the whole file, see below for the entire file.

### Backup

This config is backed up by default as it exists on Dionysus, however, I plan to make offsite backups and this
configuration would be included in it.

## Tautulli

Tautulli is a statistic tracker for your local plex installation. It tracks everything from current users to what
the most popular TV show and Movies are, who has watched them, and how many hours have they been played for.

### Configuration

The `docker-compose.yml` file is quite sparse here, but it does not have to be complicated.

```yml
tautulli:
  container_name: tautulli
  image: tautulli/tautulli
  restart: unless-stopped
  network_mode: host
  volumes:
    - ${ROOT}/config/tautilli:/config
  environment:
    - PUID=${PUID}
    - PGID=${PGID}
    - TZ=${TIMEZONE}
  ports:
    - 8181:8181
```

**NOTE** This is just a snippet of the whole file, see below for the entire file.

### Backup

This config is backed up by default as it exists on Dionysus, however, I plan to make offsite backups and this
configuration would be included in it.

## Entire File

```yaml
version: '3.7'

services:
  vpn:
    container_name: vpn
    image: dperson/openvpn-client
    cap_add:
      - net_admin
    restart: always
    volumes:
      - /dev/net:/dev/net:z
      - ${ROOT}/config/vpn:/vpn
    security_opt:
      - label:disable
    ports:
      - 8111:80
      - 9117:9117
    command: '-f "" -r 192.168.1.0/24'

  plex:
    container_name: plex
    image: plexinc/pms-docker:beta
    restart: always
    network_mode: host
    environment:
      - TZ=${TIMEZONE}
      - PLEX_CLAIM=${PLEX_CLAIM}
    volumes:
      - ${ROOT}/config/plex/db:/config
      - ${ROOT}/config/plex/transcode:/transcode
      - /volume1/media:/data
    devices:
      - /dev/dri:/dev/dri

  sonarr:
    container_name: sonarr
    image: linuxserver/sonarr
    restart: always
    network_mode: host
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TIMEZONE}
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ${ROOT}/config/sonarr:/config
      - /volume1/media/tv:/tv
      - ${ROOT}/downloads:/downloads

  radarr:
    container_name: radarr
    image: linuxserver/radarr
    restart: always
    network_mode: host
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TIMEZONE}
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ${ROOT}/config/radarr:/config
      - ${ROOT}/downloads:/downloads
      - /volume1/media/movies:/movies

  jackett:
    container_name: jackett
    image: linuxserver/jackett
    restart: always
    network_mode: service:vpn
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TIMEZONE}
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ${ROOT}/downloads/blackhole:/downloads
      - ${ROOT}/config/jackett:/config

  rutorrent:
    image: linuxserver/rutorrent
    container_name: rutorrent
    network_mode: service:vpn
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
    volumes:
      - ${ROOT}/config/rutorrent:/config
      - ${ROOT}/downloads:/downloads
    restart: always

```
