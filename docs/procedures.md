# Procedures

This section will document general procedures on how my homelab functions.

## Backups

In general, anything that needs a backup is stored in `/volume1/backups/[service]` on Dionysus. This is a 1TB folder
which is encrypted on the NAS.

Most backup scripts follow a similar format.

1. Find any file, or set of files that are older than the retention time, and delete them.
2. Copy the new backup to the mounted folder, and find the file size of that backup.
3. Send a notification to Discord containing the service that was backed up, the file size and the time and date.

These scrips run with cron at the desired backup interval. Each service has a dedicated section on how it is backed up.
Refer to those to find out more on a service-by-service breakdown.

## Restoring A Backup

This depends greatly on the service, as such each service section has a `Restoration` section. Refer to those sections
to understand how this works.

## Connecting to my HomeLab

I have set up my network and DNS in such a way to allow me to SSH to my HomeLab from anywhere in the world, except for China.
To do this, I used [Cloudflare](https://cloudflare.com) to allow me to use dynamic dns, as my home IP is not static. Then
I set up my domains to proxy through Cloudflare to hide my IP. Now you may be wondering how I connect home if my IP is hidden
from the world. The answer is disabling Cloudflare proxy on a subdomain. This allows my IP to exposed through a domain name
dynamically!
