---
title: HedgeDoc
description: Configuration files and backup script for HedgeDoc, a web editor for markdown notes and contains everything from college notes to personal journal entries and todo lists.
tags: [services, hedgedoc, backup]
---

HedgeDoc is running in a docker container. HedgeDoc is a web editor for markdown notes and contains everything from
college notes to personal journal entries and todo lists.

It's available [here](https://md.james-hackett.ie).

The repository which the container is from is located on the [hedgedoc/container](https://github.com/hedgedoc/container)
repo.

## Configuration

All configuration is done through nomad. The configuration is located in the
[nomad/hedgedoc.hcl](https://github.com/DistroByte/nomad/blob/master/hedgedoc.hcl) file.

Environment variables control the configuration of the container, with the most important one being the domain.

## Backup Strategy

HedgeDoc is backed up every 3 hours to `/backups/hedgedoc/` on Dionysus. The files are then kept for 14 days
before being removed. If the backup fails, a ping is sent to a Discord channel with the filename and date of the backup.

The script which `cron` runs is shown below. It execs into the hedgedoc-database container and runs `pg_dump`. This is
then sent to the mounted backup folder. The script then removes files older than 14 days and gets the file size of the most
recent backup. Finally a notification is sent to Discord if the backup fails, otherwise, the script exits cleanly.

The script that runs the backup task is defined in a nomad "batch" job [here](https://github.com/DistroByte/nomad/blob/master/hedgedoc-backup.hcl)

If you just want the bash script that backs up the database, click on the "Bash script" tab below.

??? note "Nomad Job"

    ```hcl
    job "hedgedoc-backup" {
      datacenters = ["dc1"]
      type        = "batch"

      periodic {
        cron             = "0 */3 * * * *"
        prohibit_overlap = true
      }

      group "db-backup" {
        task "postgres-backup" {
          driver = "raw_exec"

          config {
            command = "/bin/bash"
            args    = ["local/script.sh"]
          }

          template {
            data = <<EOH
    #!/bin/bash

    file=/backups/hedgedoc/hedgedoc-$(date +%Y-%m-%d_%H-%M-%S).sql

    docker exec $(docker ps -aqf "name=^hedgedoc-db-*") pg_dump hedgedoc -U hedgedoc > "${file}"

    find /backups/hedgedoc/hedgedoc* -ctime +14 -exec rm {} \;

    file_size=$(find $file -exec du -sh {} \; | cut -f1 | xargs | sed 's/$//')

    if test -f "$file"; then
      exit 0
    else
      curl -H "Content-Type: application/json" -d '{"content": "`HedgeDoc` backup has just **FAILED**\nFile name: `'"$file"'`\nDate: `'"$(TZ=Europe/Dublin date)"'`"}' {{ key "discord/log/webhook" }}
    fi
    EOH

            destination = "local/script.sh"
          }

          template {
            data = <<EOH
    # as service 'db-task' is registered in Consul
    # we wat to grab its 'alloc' tag
    {{- range $tag, $services := service "db-task" | byTag -}}
    {{if $tag | contains "alloc"}}
    {{$allocId := index ($tag | split "=") 1}}
    DB_ALLOC_ID="{{ $allocId }}"
    {{end}}
    {{end}}
            EOH
            destination = "secrets/file.env"
            env         = true
          }
        }
      }
    }
    ```

??? note "Bash script"

    ```bash
    #!/bin/bash

    file=/backups/hedgedoc/hedgedoc-$(date +%Y-%m-%d_%H-%M-%S).sql

    docker exec $(docker ps -aqf "name=^hedgedoc-db-*") pg_dump hedgedoc -U hedgedoc > "${file}"

    find /backups/hedgedoc/hedgedoc* -ctime +14 -exec rm {} \;

    file_size=$(find $file -exec du -sh {} \; | cut -f1 | xargs | sed 's/$//')

    if test -f "$file"; then
      exit 0
    else
      curl -H "Content-Type: application/json" -d '{"content": "`HedgeDoc` backup has just **FAILED**\nFile name: `'"$file"'`\nDate: `'"$(TZ=Europe/Dublin date)"'`"}' {{ key "discord/log/webhook" }}
      # `{{ key "discord/log/webhook" }}` is the webhook URL for the Discord channel
    fi
    ```
