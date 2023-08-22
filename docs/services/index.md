---
title: Services
description: A TL;DR of the various services I run, and how they're configured.
tags: [services]
---

I run the vast majority of my services in docker containers orchestrated by [nomad](https://www.nomadproject.io/). This
enhances portability and helps with continuity of service.

[DistroByte/nomad](https://github.com/DistroByte/nomad) contains the configuration for any of my jobs that use nomad.
There are some environment variables that are populated with [consul](https://www.consul.io/). I'll link to some oddities
and notes I found while running these various services in this section.
