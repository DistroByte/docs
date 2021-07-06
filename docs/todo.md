# TODO

- add grafana
- [Gitlab](https://docs.gitlab.com/omnibus/docker/#install-gitlab-using-docker-compose)
- [The Forest Dedicated Server](https://hub.docker.com/r/jammsen/the-forest-dedicated-server)
- cloudflare origin certs
    - go to origin cert
    - save them to server
- ELK
    - elastisearch
    - Kibana
    - Logstash
- TICK
    - Telegraf
    - Influx
    - Kapacitor
    - Chronograph
- Implement docs.james-hackett.ie with mkdocs-material

## Notes

To allow PiHole have iFrames edit `/etc/lighttpd/lighttpd.conf` and comment the line that says `"X-Frame-Options" => "DENY"`.
Run `sudo service lighttpd restart` to apply change.

## Network Topology

- planned network config
    - .1 router
    - .2 zeus (optiplex)
    - .3 hermes (optiplex)
    - .4 dionysus (NAS)
    - .5 artemis (raspi 4b)
    - .6 apollo (raspi 4b)
    - .7 ares (odroid)
    - .10 poseidon (james pc)
    - .20 bobmarley (printer)
