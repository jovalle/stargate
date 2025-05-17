<div align="center">

<img src="./stargate.jpg" height="400px"/>

# Stargate

Provides a warp link strong enough to call ships to a planet's surface

</div>

## 📖 Overview

Homelab essential services (DNS, DHCP, etc.)

## 🧰 Components

- [AdGuard Home](https://github.com/AdguardTeam/Adguardhome): Network-wide ad blocking via built-in DNS. Replaces [Pi-Hole](https://pi-hole.net)
- [AdGuardHome Sync](https://github.com/bakito/adguardhome-sync): Synchronizes instances of AdGuard Home for HA deployments.
- [Cloudflare DDNS](https://hub.docker.com/r/oznu/cloudflare-ddns/): Dynamic DNS client for updating upstream DNS records
- [Cloudflared](https://github.com/cloudflare/cloudflared): Cloudflare tunnel for remote access without exposing ports on WAN
- [Docker Socket Proxy](https://github.com/Tecnativa/docker-socket-proxy): Secured proxy for Homepage to watch Docker
- [Node Exporter](https://github.com/prometheus/node_exporter): Presents host resource metrics to be consumed by Prometheus and displayed by Grafana
- [Portainer](https://portainer.io): Web app for managing container stacks remotely
- [Tailscale](https://tailscale.com): WireGuard powered, infrastructure agnostic, VPN service
- [Traefik](https://traefik.io): Reverse proxy for serving other components with HTTPS enabled URLs. Using Let's Encrypt for quick and easy HTTPS certificates.
- [Uptime Kuma](https://github.com/louislam/uptime-kuma): Monitoring dashboard and alerting for internal and external endpoints.
- [Watchtower](https://containrrr.dev/watchtower/): Keeps an eye on colocated containers and updates them while I'm (hopefully) sleeping.

## 📋 Environment Variables

A `.env` is no longer needed to store secrets. All secrets are now defined in `docker-compose.yaml` and encrypted in-line using `sops` and `age`.

Store only common variables applicable to all compose services:

```bash
DOMAIN="example.net"
PGID=1000
PUID=1000
TZ="America/New_York"
```

## Encryption

To encrypt `docker-compose.yaml`:

```bash
sops --encrypt --age $(cat $SOPS_AGE_KEY_FILE | grep -oP "public key: \K(.*)") --encrypted-regex '(?i)^(.*(?:key|token|pass(word)?|secret|email|domain(s)?|username|deviceid).*)$' --in-place dock
er-compose.yaml
```

[`vscode-sops`](https://marketplace.visualstudio.com/items?itemName=signageos.signageos-vscode-sops) is very handy for managing the encrypted file.

### Decryption

Should you need to decrypt the file outright:

```bash
sops --decrypt --age $(cat $SOPS_AGE_KEY_FILE | grep -oP "public key: \K(.*)") --in-place docker-compose.yaml
```
