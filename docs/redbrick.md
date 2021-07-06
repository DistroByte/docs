# Redbrick

A collection of useful commands and helpful advice for both myself and aspiring admins.

## Update DNS

Connect to Paphos
cd /etc/bind/master
Backup zone file `db.Redbrick.dcu.ie`
Run `rdnc freeze redbrick.dcu.ie` (produces no output)
Update serial number (line 4, format: YYYYMMDD(number of changes))
Add new domain under the $ORIGIN that you need (based on "tld")
Run `rndc thaw [domain]`
`service bind9 status`
`named-checkzone (zone file/db.Redbr...)` check zone to make sure it follows syntax and is valid record
`var/log/named/(default.log)` are logs of dns errors (pretty shit)
