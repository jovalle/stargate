# stargate
Provides a warp link strong enough to call ships to a planet's surface

## Environment Variables

Services in `docker-compose.yaml` are currently set to pull environment variables from .env. This file is not included in the repo due to the sensitive nature of certain variables. An example of what you may find:

```
# Common
CF_EMAIL="REDACTED"
CF_TOKEN="REDACTED"
DOMAIN="example.net"
PGID=1000
PUID=1000
TZ="America/New_York"

# Feature gates
PROFILE="--profile internal --profile vpn"

# cloudflared
CLOUDFLARED_TOKEN="REDACTED"

# cloudflare-ddns
API_KEY="${CF_TOKEN}"
ZONE="${DOMAIN}"
SUBDOMAIN="stargate"
PROXIED=true

# pi-hole
WEBPASSWORD="REDACTED"

# traefik
CLOUDFLARE_DNS_API_TOKEN="${CF_TOKEN}"
CLOUDFLARE_EMAIL="${CF_EMAIL}"
TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_EMAIL="${CF_EMAIL}"
VIRTUAL_HOST="stargate.${DOMAIN}"
```

## Considerations

### Git Ignore `setupVars.conf`

As per [this](https://www.exploit-db.com/docs/49963), `WEBPASSWORD` can be found in `setupVars.conf` as a double-hashed SHA256 hash and easily crackable.

To push changes to `setupVars.conf`, remove the `WEBPASSWORD` (auto-injected at container startup) and renable tracking

```bash
git update-index --no-skip-worktree etc/pihole/setupVars.conf
```

Commit and redisable tracking

```bash
git update-index --skip-worktree etc/pihole/setupVars.conf
```
