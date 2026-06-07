---
description: Deploy to Fly.io as lightweight Firecracker microVMs. Good for full-stack apps, APIs, workers, and databases. Covers setup, config, secrets, deploy, verify, scale, and rollback. Auto-detected when fly.toml exists.
---

# Fly.io Deploy

Deploy to Fly.io — runs apps as lightweight VMs (Firecracker microVMs). Good for
full-stack apps, APIs, workers, databases. Designed for beginners.

---

## 1. Detection

The project uses Fly.io if:
- `fly.toml` in the root
- `"@flydotio/dockerfile"` or `"fly"` in dependencies/scripts
- `.fly/` folder exists

---

## 2. Determine app type

Check `fly.toml`:

```toml
app = "my-app"
primary_region = "sin"  # Singapore (lowest latency to Southeast Asia)

[build]
  builder = "heroku/buildpacks:20"  # auto-detect (Node, Python, Go, etc)

# OR

[build]
  image = "nginx:alpine"  # custom Docker image
```

If `fly.toml` doesn't exist, check `Dockerfile` — Fly.io can deploy directly from a Dockerfile.

---

## 3. Pre-Deploy Checklist

Before deploying, verify these in order:

| Step | Check | Command |
|------|-------|---------|
| **Credentials** | Is `flyctl` authenticated? | `fly auth whoami` |
| **Config valid** | Is `fly.toml` valid? | `fly config validate` (or read the file for obvious errors) |
| **Secrets ready** | Are all required secrets set? | `fly secrets list` |
| **Build** | Does the project build locally? | `{{BUILD_CMD}}` |

**If credentials fail**: guide the user to run `fly auth login` (existing account) or
`fly auth signup` (new account). Note: Fly.io requires a credit card for verification,
but the free tier covers small apps (3 shared VMs, 256MB RAM each, 3GB storage).

**If secrets are missing**: compare `fly secrets list` output with what the app
expects (check `.env.example` or `.env`). Guide user to run `fly secrets set NAME=VALUE`
for each missing secret, or bulk import with `cat .env | fly secrets import`.

---

## 4. Setup (if no config exists)

### Install CLI:
```bash
curl -L https://fly.io/install.sh | sh
# Or: brew install flyctl (macOS)
```

### Login & signup:
```bash
fly auth login
# OR (new user)
fly auth signup
```
This opens a browser. User creates an account (email or GitHub).

### Init project:
```bash
fly launch
```
The CLI will:
1. Auto-detect language/framework (Node, Python, Go, Ruby, etc.)
2. Generate `fly.toml` and `Dockerfile` (if missing)
3. Ask for region — recommend: `sin` (Singapore, low latency to Southeast Asia)
4. Ask for app name
5. Offer first deploy (can skip)

### Minimal `fly.toml` (for Node.js app):
```toml
app = "my-app"
primary_region = "sin"

[build]

[http_service]
  internal_port = 3000
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 0

[[vm]]
  memory = "256mb"
  cpu_kind = "shared"
  cpus = 1
```

---

## 5. Secrets & Environment Variables

### Set a secret:
```bash
fly secrets set DATABASE_URL=postgres://...
```

### Bulk import from `.env`:
```bash
cat .env | fly secrets import
```

### List existing secrets:
```bash
fly secrets list
```

### Remove a secret:
```bash
fly secrets unset DATABASE_URL
```

### Token:
User needs a **Fly.io access token** — auto-obtained during `fly auth login`.
For a manual token: `fly auth token`.

### For CI/GitHub Actions:
Fly has an official GitHub Action: `superfly/flyctl-actions/setup-flyctl@master`

---

## 6. Build

```bash
{{BUILD_CMD}}
```

Fly.io builds happen on their servers during deploy (remote builder). So `{{BUILD_CMD}}`
may not need to run locally — but still run it for verification.

If Docker-based, Fly.io builds from the `Dockerfile` remotely. Make sure `Dockerfile` is correct.

---

## 7. Deploy

```bash
fly deploy
```

This will:
1. Build the image (remote)
2. Push to registry
3. Deploy a new VM
4. Run health checks
5. Switch traffic to the new VM

### Deploy with different env:
```bash
fly deploy --env staging
```

### Deploy via git (CI-based):
Push to `{{MAIN_BRANCH}}` if GitHub Actions is set up. Manual: `fly deploy`.

---

## 8. Post-Deploy Verification

```bash
# Check app status
fly status

# View real-time logs
fly logs

# Open app in browser
fly open

# Check machines
fly machines list
```

### Report to user:
- URL: `https://<app-name>.fly.dev`
- Region: Singapore (`sin`) or whatever was chosen
- VM specs: memory, CPU, instances
- For custom domain: `fly certs create <domain>` then set up DNS

---

## 9. Rollback

```bash
# View release history
fly releases

# Rollback to previous release
fly deploy --image registry.fly.io/<app>:<release>
```

Or `fly releases rollback` — rolls back to the previous release directly.

---

## 10. Scale (if needed)

```bash
# Add VM instances
fly scale count 2

# Add memory
fly scale memory 512

# View current scale
fly scale show
```

Free tier: 3 shared VMs, 256MB each. Paid beyond that.

---

## 11. Common Gotchas

- **Port**: The app must listen on the port set via the `PORT` environment variable (usually 8080) OR the port in `fly.toml` `internal_port`. Never hardcode `3000` unless set in `fly.toml`.
- **Cold start**: Free tier machines auto-stop when idle. The first request will be slow (~2-3 seconds). Disable this by setting `min_machines_running = 1` (but this eats into the free allowance).
- **Region**: `sin` (Singapore) is closest to Southeast Asia. Avoid `iad` (US East) — high latency.
- **Build timeout**: If builds take long, add `build_timeout = 300` in `fly.toml` `[build]`.
- **Health check**: Fly.io checks `http_service.internal_port`. If the app doesn't return 200, the deploy fails. Make sure there's a health endpoint at `/` or `/health`.
- **Postgres**: If a database is needed, `fly postgres create` — but this is outside this skill's scope. Guide user to [Fly docs](https://fly.io/docs/postgres/).
