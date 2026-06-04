# Docker Deploy — Build & Push

Build a Docker image from the project and push it to a container registry
(Docker Hub, GitHub Container Registry, or others). Focused on build & push
only — no orchestration (Kubernetes, Docker Swarm, production docker-compose).

---

## 1. Detection

The project uses Docker if:
- `Dockerfile` in the root
- `docker-compose.yml` or `docker-compose.yaml` in the root
- `.dockerignore` in the root
- `"docker"` in deploy script in `package.json`

---

## 2. Determine registry

| Clue | Registry |
|------|----------|
| `docker.io/<user>/<image>` in docs/README | **Docker Hub** |
| `ghcr.io/<user>/<image>` in docs/README | **GitHub Container Registry (GHCR)** |
| `.gitlab-ci.yml` contains `docker push` | **GitLab Container Registry** |
| No clue found | **Ask user** — where to push? Recommendation: Docker Hub (most common) |

---

## 3. Pre-Deploy Checklist

Before building and pushing, verify these in order:

| Step | Check | Command |
|------|-------|---------|
| **Credentials** | Is Docker daemon running + logged in? | `docker info` then attempt silent pull of a known image |
| **Config valid** | Is `Dockerfile` valid? | Read the file, check for obvious syntax errors |
| **.dockerignore** | Does `.dockerignore` exist and exclude `node_modules`, `.env`, `.git`? | Read the file; generate if missing |
| **No secrets in image** | Are there any hardcoded secrets in `Dockerfile`? | Scan `Dockerfile` for `ENV` with secret-like values |
| **Build** | Does the project build? | `{{BUILD_CMD}}` |

**Dockerfile validity check (read the file, look for):**
- `FROM` is the first non-comment instruction
- No hardcoded secrets in `ENV` instructions
- `COPY . .` comes AFTER `COPY package*.json` and `npm ci`
- A health endpoint exists if the app is a web service

---

## 4. Setup (if no config exists)

### Docker Hub:
1. User needs an account at [hub.docker.com](https://hub.docker.com) (free)
2. Login: `docker login`
3. Enter username & password (or access token — more secure)

### GitHub Container Registry (GHCR):
1. User needs a GitHub Personal Access Token (classic) with `write:packages` scope
2. Login:
```bash
echo "$GITHUB_TOKEN" | docker login ghcr.io -u <github-username> --password-stdin
```

### GitLab Container Registry:
```bash
docker login registry.gitlab.com -u <username> -p <token>
```

### Dockerfile minimal check:
If `Dockerfile` doesn't exist, offer to generate one. Minimal example for Node.js:
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]
```

But **do NOT generate without user request** — Dockerfiles are very project-specific.

---

## 5. `.dockerignore`

Make sure `.dockerignore` exists and excludes:
```
node_modules
.git
.env
*.log
.DS_Store
dist  # (if building inside Docker)
```

If missing, generate it.

---

## 6. Build

```bash
{{BUILD_CMD}}
```

Then build the Docker image:

```bash
# Build with tag
docker build -t <registry>/<username>/<image>:<tag> .

# Examples:
docker build -t docker.io/myuser/myapp:latest .
docker build -t ghcr.io/myuser/myapp:latest .
```

### Versioning tags:
- `latest` — production (default)
- `v1.0.0` — if there's a git tag
- `<git-sha>` — commit hash (for traceability)
- `<date>` — if a timestamp tag is needed

Recommendation: push `latest` + `<git-sha>` (so you can trace back to the commit).

```bash
# Build with 2 tags
docker build -t myuser/myapp:latest -t myuser/myapp:$(git rev-parse --short HEAD) .
```

---

## 7. Push

```bash
docker push <registry>/<username>/<image>:<tag>
```

### Push multiple tags:
```bash
docker push myuser/myapp:latest
docker push myuser/myapp:$(git rev-parse --short HEAD)
```

### For GHCR:
```bash
# Tag must include ghcr.io prefix
docker tag myapp ghcr.io/myuser/myapp:latest
docker push ghcr.io/myuser/myapp:latest
```

---

## 8. Post-Push Verification

```bash
# Verify the image exists in the registry
docker pull <registry>/<username>/<image>:<tag>

# Run locally to test
docker run -p 3000:3000 --rm <registry>/<username>/<image>:<tag>
# Ctrl+C to stop

# Check image size
docker images <registry>/<username>/<image>
```

### Report to user:
- Image URL: `docker.io/myuser/myapp:latest` or `ghcr.io/myuser/myapp:latest`
- Image size
- How to pull: `docker pull <url>`
- How to run: `docker run -p <host-port>:<container-port> <url>`

### Next steps (for the user):
After the image is in the registry, deploy to a Docker-compatible hosting:
- **Fly.io**: `fly launch --image <url>` (load `fly-deploy` skill)
- **Railway**: Connect GitHub repo, auto-detect Dockerfile
- **Render**: Web Service → Deploy from Docker image
- **VPS**: `docker pull <url> && docker run ...`
- **Kubernetes**: `kubectl set image deployment/<name> <container>=<url>` (advanced — point user to docs)

Offer the user: "Where should I deploy this image? I can help set up Fly.io, Railway, or Render."

---

## 9. Rollback

```bash
# Pull the previous tag
docker pull <registry>/<username>/<image>:<previous-tag>

# Re-tag as latest (if the deployment uses latest)
docker tag <registry>/<username>/<image>:<previous-tag> <registry>/<username>/<image>:latest
docker push <registry>/<username>/<image>:latest
```

This only rolls back the image in the registry. If already deployed to a server,
the user needs to redeploy with the rolled-back image.

---

## 10. Common Gotchas

- **Image size**: Alpine-based images are much smaller. `node:20-alpine` (~120MB) vs `node:20` (~1GB). Always recommend Alpine.
- **Layer caching**: Order the Dockerfile: `package.json` + `npm ci` first, then copy source code. This reduces build time via layer caching.
- **Multi-stage build**: Use for build & production separation. Stage 1: build. Stage 2: copy artifacts only. Smaller & more secure.
- **`.dockerignore`**: Without it, `node_modules` gets copied into the image → huge image.
- **Root user**: Never run as `root`. Add `USER node` in the Dockerfile.
- **Port**: `EXPOSE` in Dockerfile is documentation only — it doesn't open ports automatically. The `-p` flag is still needed with `docker run`.
- **Secrets in image**: NEVER hardcode secrets in the Dockerfile. Use `--build-arg` or runtime env vars.
