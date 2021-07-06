# Procedures

This section will document general procedures on how my homelab functions.

## Backups

In general, anything that needs a backup is stored in `/volume1/backups/[service]` on [Dionysus](hardware/ds920plus.md).
This is a 1TB folder which is encrypted on the NAS.

Most backup scripts follow a similar format.

1. Find any file, or set of files that are older than the retention time, and delete them.
2. Copy the new backup to the mounted folder, and find the file size of that backup.
3. Send a notification to Discord containing the service that was backed up, the file size and the time and date.

These scrips run with cron at the desired backup interval. Each service has a dedicated section on how it is backed up.
Refer to those to find out more on a service-by-service breakdown.

### Step by step**

1. Create a backups folder on host (has to be empty) and a corresponding folder on NAS
2. Run `sudo apt install cifs-utils`
3. Run `mount -t cifs -o username=distro "\\\\dionysus\\backups\\[service]" '/location/of/backup'`
4. Edit `/etc/fstab` to contain connection settings `//dionysus/backups/[service] /location/of/backup cifs
  credentials=/etc/win-credentials, file_mode=0755,dir_mode=0755 0 0`
5. Create /etc/win-credentials and add `username=[username] password=password`
6. Create a script to notify Discord and remove old backups.

## Restoring A Backup

This depends greatly on the service, as such each service section has a `Restoration` section. Refer to those sections
to understand how this works.

## Connecting to my HomeLab

I have set up my network and DNS in such a way to allow me to SSH to my HomeLab from anywhere in the world, except for China.
To do this, I used [Cloudflare](https://cloudflare.com) to allow me to dynamically update my DNS entries, as my home IP
is not static. Then I set up my domains to proxy through Cloudflare to hide my IP. Now you may be wondering how I connect
home if my IP is hidden from the world. The answer is disabling Cloudflare proxy on a subdomain. This allows my IP to
exposed through a domain name dynamically.
