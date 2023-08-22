# TODO

- [The Forest Dedicated Server](https://hub.docker.com/r/jammsen/the-forest-dedicated-server)
- ELK
    - elastisearch
    - kafka
    - Logstash
- TICK
    - Telegraf
    - Influx
    - Kapacitor
    - Chronograph

## Notes

To allow PiHole have iFrames edit `/etc/lighttpd/lighttpd.conf` and comment the line that says `"X-Frame-Options" => "DENY"`.
Run `sudo service lighttpd restart` to apply change.

## Network Topology

![Network Topology](https://i.dbyte.xyz/firefox_Rpz0o5ONP.png)

### Hardware

- .1 router
- .2 hades (switch)
- .3 zeus (optiplex)
- .4 hermes (optiplex)
- .5 dionysus (NAS)
- .6 apollo (raspi 4b)
- .7 artemis (raspi 4b)
- .10 poseidon (PC)
- .11 perseus (Dell Laptop)
- .12 icarus (Galaxy Note 9)
- (.xxx) castor (Unifi AP Lite 6)

### VMs

- hera - 4core 24GB
- aphrodite - 1core 1GB
- persephone - 1core 1GB

### Other hardware names

- ares
- hephaestus
- hercules
- atlas
- charon
- cronus
- helios
- hypnos
- pan
- polux
- prometheus

### Other VM names

- demeter
- athena
- hestia

## Next PC Build

Case: SSUPD Meshalicious
CPU: Ryzen 5 3600
GPU: GeForce GTX 1660ti
RAM: 32GB
