# Media Stack

I run quite a large stack for downloading, indexing and watching media over the internt. All of these
services run on Dionysus. The stack includes:

- [Deluge](#deluge)
- [OpenVPN](#openvpn)
- [Radarr](#sonarrradarr)
- [Sonarr](#sonarrradarr)
- [Overseerr](#overseerr)
- [Jackett](#jackett)
- [Tautulli](#tautulli)
- [Plex](#plex)

These services all contribute to allow me to watch TV shows and movies very easily wherever I am in the world.

They are all managed by one large `docker-compose.yml` file, but I will go through each service individually.

## General Configuration

These services are all located in `/etc/docker-compose/plex` on Dionysus, and thus are quite easy to configure all together
using environment variables. The config for each service is located in `${ROOT}/config/$service_name` and any other directory
the service needs is created before starting the containers.

### Note

I won't dive into each individual service's configuration, that will be done on their respective pages. This will just
contain the basics of how to get the service running.

## Deluge

Deluge is a torrenting client with some nice features over other torrenting clients of similar standing. It is really fast
when it has less than 100 torrents seeding at once. Once you go above that, it slows down slightly, but not by much. I'm
using the container from [linuxserver/deluge](https://hub.docker.com/r/linuxserver/deluge). There is a compose file on that
page, but I had to adapt mine slightly to make use of the VPN I wanted to use.

### Configuration

The `docker-compose.yml` file is quite sparse, but it does not have to be complicated.

```yml
deluge:
    container_name: deluge
    image: linuxserver/deluge
    restart: unless-stopped
    network_mode: service:vpn
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TIMEZONE}
    volumes:
      - ${ROOT}/downloads:/downloads
      - ${ROOT}/config/deluge:/config
```

**NOTE** This is just a snippet of the whole file, see below for the entire file.

### Points to Note

The container will not start unless the vpn has started also, thus it is one of the last services to come up when
`docker-compose up -d` is run.

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
    restart: unless-stopped
    volumes:
      - /dev/net:/dev/net:z
      - ${ROOT}/config/vpn:/vpn
    security_opt:
      - label:disable
    ports:
      - 8112:8112
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

This config is backed up by default as it exists on Dionysus.

## Sonarr/Radarr

## Overseerr

## Jackett

## Plex

## Tautulli
