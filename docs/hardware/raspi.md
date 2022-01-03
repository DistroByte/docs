# Raspberry Pi // Apollo + Artemis

The standard device in almost any homelab, you can never have enough of them until you have too many.
Luckily for me I only have 2. They both have PoE+ hats that allow them to be connected to the internet
and get power with one cable.

## Hardware

- 1x Broadcom BCM2711 CPU @ 1.5GHz
- 2GB RAM
- 16GB USB Drive
- PoE+ Hat
- The Pi Hut Laser Cut Case

## Services

The services running on the Raspberry Pis are listed here. This list is updated frequently.

As my HomeLab has two identical Raspberry Pis, it can run many services in a hot-hot/hot-cold format.

| Service Name | Description                            | Highly Available? |
| ------------ | -------------------------------------- | ----------------- |
| Pihole       | Network-wide adblocker and DHCP Server | Yes               |

!!!info

    Anything marked as Highly Available is run in either a hot-hot or hot-cold
    setup depending on the importance of the service.

## Images

![Raspis with cases](https://i.dbyte.xyz/2021-07-A4.jpg)
![Raspi Hats](https://i.dbyte.xyz/2021-07-B7.jpg)
