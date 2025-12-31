<div align="center">

<img src="./.github/assets/logo.png" height="400"/>

# Stargate

Provides a warp link strong enough to call ships to a planet's surface

![Node Uptime](https://img.shields.io/endpoint?url=https://stat.techn.is/query?metric=stargate_uptime&style=flat&label=uptime) ![CPU Usage](https://img.shields.io/endpoint?url=https://stat.techn.is/query?metric=stargate_cpu_usage&style=flat&label=cpu) ![Memory Usage](https://img.shields.io/endpoint?url=https://stat.techn.is/query?metric=stargate_memory_usage&style=flat&label=memory) ![Docker Containers](https://img.shields.io/endpoint?url=https://stat.techn.is/query?metric=stargate_containers_running&style=flat&label=running)

</div>

## ✨ Overview

Stargate is a batteries-included Docker Compose collection that keeps a homelab reachable, observable, and secure. It brings together reverse proxies, DNS, certificate management, telemetry, and automated updates so day-to-day upkeep stays low-effort while resiliency stays high.

## 🚀 Highlights

- End-to-end encrypted access for internal services without opening inbound firewall ports.
- Automated DNS, certificate issuance, and dynamic IP syncing for smooth domain management.
- Unified observability via uptime checks, resource metrics, and health dashboards.
- Safe automation layers (socket proxy, watchtower) that reduce blast radius while enabling self-healing updates.
- Built for portability: drop the stack on any Docker-capable host and customize via environment variables. Works well with [nexus](https://github.com/jovalle/nexus)!

## 🧰 Service Lineup

| Service | Purpose | Notes |
| --- | --- | --- |
| AdGuard Home | DNS-level filtering and DHCP | Primary network edge with optional multi-instance sync. |
| AdGuardHome Sync | Config sync | Keeps multiple AdGuard nodes aligned. |
| Beszel Agent | Lightweight telemetry | Streams host metrics into the Beszel dashboard. |
| Cloudflare DDNS | Dynamic DNS | Updates public DNS with the current WAN IP. |
| Cloudflared | Zero-trust tunnels | Publishes internal services through Cloudflare without port forwarding. |
| CrowdSec | Collaborative IPS | Detects and blocks malicious behavior via community threat intelligence. |
| CrowdSec Traefik Bouncer | Traffic enforcement | Integrates CrowdSec decisions with Traefik reverse proxy. |
| Docker Socket Proxy | Hardened Docker access | Limits what dashboards can trigger against the Docker daemon. |
| Nginx Proxy Manager | TLS reverse proxy | Friendly UI for ingress rules and certificates. |
| Node Exporter | System metrics | Prometheus-compatible metrics endpoint for the host. |
| ntfy | Push notifications | Self-hosted pub-sub notification service with authentication and rate limiting. |
| Orb | Latency & throughput checks | Speed tests and monitoring. |
| Tailscale | Mesh VPN | Securely links remote clients to the homelab network. |
| Traefik | Smart edge router | Automates HTTPS via Let's Encrypt and routes to services. |
| Uptime Kuma | Synthetic monitoring | Pings, HTTP checks, keyword checks, and alerting. |
| Watchtower | Automated updates | Rolls containers forward on new image builds. |

## 🛠️ Getting Started

### Install

1. Clone the repository to your homelab host.

   ```sh
   git clone https://github.com/jovalle/stargate.git
   cd stargate
   ```

2. Create `.env`  and populate it with your secrets (see the table below). It should not be committed (as per `.gitignore`) but tread carefully anyways.

   ```sh
   vim .env
   ```

3. Review `docker-compose.yaml` and adjust any service-specific volumes, ports, or networks.

4. Bring the stack online.

   ```sh
   docker compose up -d
   ```

5. Visit the exposed web UIs (for example Traefik, Nginx Proxy Manager, Uptime Kuma) through your tunnel or VPN and finish any first-run onboarding.

### Updating

- To refresh service images manually: `docker compose pull && docker compose up -d`.
- Watchtower is enabled by default. If you prefer manual control, disable or set its scope in `docker-compose.yaml`.

## 🔐 Environment Variables

All secrets and configuration values live in `.env`. See `.env.example` for a sample. The compose file reads them automatically at deploy time. Rotate them regularly and store backups in your secret manager of choice.

> ❗️ Tip: keep real secrets in `.env` or a secret manager like 1Password or Vault, then inject them into the host environment before running `docker compose up`.
