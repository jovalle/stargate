<div align="center">

<img src="./stargate.jpg" height="400px"/>

# Stargate

Provides a warp link strong enough to call ships to a planet's surface

</div>

## 📖 Overview

Homelab essential services (DNS, DHCP, etc.)

An extension of [Mothership](https://github.com/jovalle/mothership).

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

A `.env` is no longer needed to store secrets. All secrets are now defined in `docker-compose.yaml` and encrypted in-line using `sops` and `age`.

Store only common variables applicable to all compose services:

```
DOMAIN="example.net"
PGID=1000
PUID=1000
TZ="America/New_York"
```
