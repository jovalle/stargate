<div align="center">

<img src="./stargate.jpg" height="400px"/>

# Stargate

Provides a warp link strong enough to call ships to a planet's surface

</div>

## 📖 Overview

Homelab essential services (DNS, DHCP, etc.)

An extention of [Mothership](https://github.com/jovalle/mothership).

## 🧰 Components

- [Cloudflare DDNS](https://hub.docker.com/r/oznu/cloudflare-ddns/): Dynamic DNS client for updating upstream DNS records
- [Cloudflared](https://github.com/cloudflare/cloudflared): Cloudflare tunnel for remote access without exposing ports on WAN
- [Docker Socket Proxy](https://github.com/Tecnativa/docker-socket-proxy): Secured proxy for Homepage to watch Docker
- [Nebula Sync](https://github.com/lovelaze/nebula-sync): Synchronizes multiple instances of pi-hole for HA deployments
- [Node Exporter](https://github.com/prometheus/node_exporter): Presents host resource metrics to be consumed by Prometheus and displayed by Grafana
- [Pi-Hole](https://pi-hole.net): Network-wide ad blocking with built-in DNS and DHCP servers.
- [Portainer](https://portainer.io): Web app for managing container stacks remotely
- [Tailscale](https://tailscale.com): WireGuard powered, infrastructure agnostic, VPN service
- [Traefik](https://traefik.io): Reverse proxy for serving other components with HTTPS enabled URLs. Using Let's Encrypt for quick and easy HTTPS certificates.
- [Uptime Kuma](https://github.com/louislam/uptime-kuma): Monitoring dashboard and alerting for internal and external endpoints.
- [Watchtower](https://containrrr.dev/watchtower/): Keeps an eye on colocated containers and updates them while I'm (hopefully) sleeping.

## 📋 Environment Variables

Docker compose services inherit the following env vars (update yours accordingly):

```sh
# common
ADMIN_PASSWORD=""
ADMIN_PASSWORD_HASH=""
DOMAIN=""
PGID=1000
PUID=1000
TZ=""

# cloudflare
CF_EMAIL=""
CF_TOKEN=""
CF_ZONE=""

# cloudflared
CLOUDFLARED_TOKEN=""

# homepage
PIHOLE_API_KEY=""
PORTAINER_API_KEY=""

# tailscale
TS_AUTHKEY=""
```
