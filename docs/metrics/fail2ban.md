# Fail2Ban

Fail2ban is running on my main SSH host Zeus. The service [`fail2ban_exporter`](https://gitlab.com/hectorjsmith/fail2ban-prometheus-exporter)
runs on zeus also and exposes metrics collected from the fail2ban socket. Prometheus then collects that information and
Grafana displays it.

## Config

### Service file

Located in `/etc/systemd/system/fail2ban_exporter.service`

```service
[Unit]
Description=Fail2Ban Exporter

[Service]
User=root
ExecStart=/usr/local/bin/fail2ban_exporter --collector.f2b.socket=/var/run/fail2ban/fail2ban.sock --web.listen-address=":9191"

[Install]
WantedBy=multi-user.target
```

### Networking

| Host | Port | Endpoint |
| ---- | ---- | ---- |
| Zeus | 9191 | "/metrics" |
