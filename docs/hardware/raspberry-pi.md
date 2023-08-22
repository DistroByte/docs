# Raspberry Pis

The standard device in almost any homelab, you can never have enough of them until you have too many.
I have 4. They all have PoE+ hats that allow them to be connected to the internet
and get power with one cable.

| CPU                    | RAM | Storage        | OS          | Extras   |
| ---------------------- | --- | -------------- | ----------- | -------- |
| Broadcom BCM2711 (ARM) | 2GB | 16GB USB Drive | Raspbian 11 | PoE+ Hat |

## Services

The services running on the Raspberry Pis are listed here. This list is updated frequently.

As my HomeLab has two identical Raspberry Pis, it can run many services in a hot-hot/hot-cold format.

| Service Name                   | Description                            | Highly Available? | Hostname       |
| ------------------------------ | -------------------------------------- | ----------------- | -------------- |
| [Pihole](http://pi.hole/admin) | Network-wide adblocker and DHCP Server | Yes               | Apollo/Artemis |

!!!info

    Anything marked as Highly Available is run in either a hot-hot or hot-cold
    setup depending on the importance of the service.

## Images

![Raspis with cases](https://i.dbyte.xyz/2021-07-A4.jpg)
![Raspi Hats](https://i.dbyte.xyz/2021-07-B7.jpg)
