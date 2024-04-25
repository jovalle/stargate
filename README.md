# stargate
Provides a warp link strong enough to call ships to a planet's surface

## Environment Variables

Each service in `docker-compose.yaml` should have `env_file` defined as `.env`. This file is to be a local-only copy storing any and all variables that all services can benefit from (permissions, timezone and domain for ingress are the key ones). See an example below.

If docker secrets are not supported by a service (e.g. `_FILE` env vars) then the credential or sensitive data can be stored in .env. Of course, use this method at your own risk.

```
# common
DOMAIN="example.net"
PGID=1000
PUID=1000
TZ="America/New_York"

# cloudflare
CF_EMAIL="REDACTED"
CF_TOKEN="REDACTED"

# cloudflared
CLOUDFLARED_TOKEN="REDACTED"
```
