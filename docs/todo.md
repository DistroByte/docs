# TODO

- [The Forest Dedicated Server](https://hub.docker.com/r/jammsen/the-forest-dedicated-server)
- ELK
    - elastisearch
    - Kibana
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

- Hardware
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

- VMs
    - hera - 4core 24GB
    - aphrodite - 1core 1GB
    - persephone - 1core 1GB

- Other hardware names
    - ares
    - hephaestus
    - hercules
    - atlas
    - charon
    - cronus
    - helios
    - hypnos
    - pan
    - castor // polux
    - proemtheus

- Other VM names
    - demeter
    - athena
    - hestia
