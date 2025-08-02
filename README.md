<div align="center">

<img src="./stargate.jpg" height="400px"/>

# Stargate

Provides a warp link strong enough to call ships to a planet's surface

</div>

## 📖 Overview

Homelab essential services (DNS, DHCP, etc.)

## 🧰 Components

- [AdGuard Home](https://github.com/AdguardTeam/Adguardhome): Network-wide ad blocking via built-in DNS. Replaces [Pi-Hole](https://pi-hole.net).
- [AdGuardHome Sync](https://github.com/bakito/adguardhome-sync): Synchronizes instances of AdGuard Home for HA deployments.
- [Beszel Agent](https://www.beszel.dev/): Lightweight server monitoring.
- [Cloudflare DDNS](https://hub.docker.com/r/oznu/cloudflare-ddns/): Dynamic DNS client for updating upstream DNS records.
- [Cloudflared](https://github.com/cloudflare/cloudflared): Cloudflare tunnel for remote access without exposing ports on WAN.
- [Docker Socket Proxy](https://github.com/Tecnativa/docker-socket-proxy): Secured proxy for Homepage to watch Docker.
- [Nginx Proxy Manager](https://nginxproxymanager.com/): Network-wide reverse proxying.
- [Node Exporter](https://github.com/prometheus/node_exporter): Presents host resource metrics to be consumed by Prometheus and displayed by Grafana.
- [Orb](https://orb.net): Continuous network performance and health monitoring.
- [Tailscale](https://tailscale.com): WireGuard powered, infrastructure agnostic, VPN service.
- [Traefik](https://traefik.io): Reverse proxy for serving other components with HTTPS enabled URLs. Using Let's Encrypt for quick and easy HTTPS certificates.
- [Uptime Kuma](https://github.com/louislam/uptime-kuma): Monitoring dashboard and alerting for internal and external endpoints.
- [Watchtower](https://containrrr.dev/watchtower/): Keeps an eye on colocated containers and updates them while I'm (hopefully) sleeping.

## 📋 Environment Variables

Use `.env` to provide/override variables set throughout `docker-compose.yml`. Only containers referencing changed variables will be restarted.

```sh
ADMIN_EMAIL="REDACTED"
ADMIN_PASSWORD="REDACTED"
ADMIN_USERNAME="REDACTED"
ADMIN2_PASSWORD="REDACTED"
BESZEL_KEY="REDACTED"
CLOUDFLARE_API_TOKEN="REDACTED"
CLOUDFLARE_EMAIL="REDACTED"
CLOUDFLARED_TOKEN="REDACTED"
DOMAIN="REDACTED"
PGID=1000
PUID=1000
TAILSCALE_AUTH_KEY="REDACTED" # only needed when onboarding new devices
TAILSCALE_DEVICE_ID="REDACTED"
TAILSCALE_DEVICE_KEY="" # rotate every 90d
TZ="America/New_York"
```
