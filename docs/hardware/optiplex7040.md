# Dell OptiPlex 7040 // Zeus + Hermes

These small servers are perfect for an ITX sized homelab. They provide enough computing power for most tasks
and combined have 16GB of RAM. These servers were the first of my actual hardware I bought.

## Hardware

- 1x Intel(R) Core(TM) i5-6500T CPU @ 2.50GHz
- 8GB RAM
- 1x 500GB HDD (Hermes), 1x 250GB SSD (Zeus)

## Services

The services running on the Dell OptiPlexes are listed here. This list is updated frequently.

As my HomeLab has two quite similar Dell OptiPlexes, it can run many services in a hot-hot/hot-cold format.
When listing what services are running, the hostname will be listed beside it.

| Service Name     | Description                                     | Highly Available? |
| ---------------- | ----------------------------------------------- | ----------------- |
| Traefik          | Reverse Proxy manager                           |                   |
| Unifi Controller | Controls and manages the Ubuiquiti Switch       |                   |
| Paperless-ng     | Document storage                                |                   |
| HedgeDoc         | Collaborative Markdown Editor                   |                   |
| ddclient         | IP address updater for Cloudflare               |                   |
| Tautulli         | Plex statistic tracker                          |                   |
| Overseerr        | Friendly user interface for Movies and TV shows |                   |
| Home Assistant   | Home Automation Software                        |                   |
| OpenVPN          | VPN for connecting to Homelab from the internet | No                |

!!!info

    Anything marked as Highly Available is run in either a hot-hot or hot-cold
    setup depending on the importance of the service.

## Notes

### Converting from Windows to New OS

1. Create a bootable USB with desired operating system
2. When booting up, press F2
3. Allow "boot from USB" in BIOS
4. Follow installer instructions

## Images

![Optiplex](https://i.dbyte.xyz/2021-07-Iv.jpg)
![Optiplex](https://i.dbyte.xyz/2021-07-EX.jpg)
![Optiplex](https://i.dbyte.xyz/2021-07-00.jpg)
