# Dell OptiPlex 7040 // Zeus + Hermes

These small servers are perfect for an ITX sized homelab. They provide enough computing power for most tasks
and combined have 16GB of RAM. These servers were the first of my actual hardware I bought.

## Specifications

| CPU            | RAM | Storage   | OS        | Hostname |
| -------------- | --- | --------- | --------- | -------- |
| Intel i5-6500T | 8GB | 250GB SSD | Debian 12 | zeus     |
| Intel i5-6500T | 8GB | 250GB SSD | Debian 12 | hermes   |

## Services

Both of these servers are part of a nomad datacentre that alloctes jobs on any available node according to the
scheduler. You can find out more about the service running in this cluster
[here](https://github.com/DistroByte/nomad).

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
