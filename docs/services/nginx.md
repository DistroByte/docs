# Nginx

[Nginx](https://www.nginx.com/) is an easy to work with webserver that I think is easier to work
with than Apache. I run Nginx on every host that needs access to the web, and also on
[Zeus](/hardware/optiplex7040/). [Hermes](/hardware/optiplex7040/) is my official web server, but all my web and ssh
traffic gets pointed to Zeus before being proxied to the correct place. For example, my main website is located on Hermes,
and therefore any request containing just `james-hackett.ie` is sent to Hermes. Other services run on other hosts that get
proxied as needed.

## Configuration

My router has a port forwarding rule to send all traffic on ports 80 and 443 to Zeus. Zeus then proxies the traffic to
Hermes for certain sites, and to Dionysus for others. The configuration contains lots of little bits so it is quite long.

<!-- TODO: add nginx configs -->
