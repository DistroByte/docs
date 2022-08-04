# Metrics & Alerting

Every good system has metrics and alerting, and my homelab is no different!

## Stack

My metrics and alerting system makes use of a couple of components:

- Grafana for displaying the data
- Prometheus as a time series database
- Various exporters
    - `prometheus-node-exporter` for performance metrics on each node
    - `fail2ban_exporter` for fail2ban jail metrics on zeus
    - `openvpn_exporter` for VPN connection monitoring and logging on zeus
    - [`rtorrent_exporter`](https://github.com/mdlayher/rtorrent_exporter.git) for monitoring rtorrent data on hermes

## Alerting

I use Grafana's alerting system to post to a Discord webhook to alert me of any issues.

This works quite well, however it displays slightly ugly. There may be a way to pretty it up, but I have
yet to find out how.

### Current Alerts

| Alert Name | Trigger |
| ---------- | ------- |
| High CPU Usage | 15m load average is greater than the CPU core count minus 1 |
