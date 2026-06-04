# Cloudflare Deploy — Workers & Pages

Deploy to Cloudflare Workers (API/backend) or Pages (static/full-stack). Covers
setup, config, secrets, deploy, verify, and rollback. Designed for beginners.

---

## 1. Detection

The project uses Cloudflare if any of these exist:
- `wrangler.toml` or `wrangler.jsonc` in the root
- `"wrangler"` in `devDependencies`/`dependencies` in `package.json`
- `"deploy"` script in `package.json` contains `wrangler`

---

## 2. Determine: Workers or Pages?

| Trait | Workers | Pages |
|-------|---------|-------|
| Config file | `wrangler.toml`/`wrangler.jsonc` | `wrangler.toml`/`wrangler.jsonc` (or none, git-based) |
| Framework | Hono, Itty-Router, plain `fetch` handler | Next.js, Astro, Remix, SvelteKit, static HTML |
| Build output | `main` field in wrangler config | `dist/`, `out/`, `.next/`, `.vercel/output/static` |
| Deploy command | `npx wrangler deploy` | `npx wrangler pages deploy <dir>`, or git-based CI |

**How to tell them apart:**
1. Check `wrangler.toml`/`wrangler.jsonc` — if `pages_build_output_dir` exists → Pages. If `main` exists → Workers.
2. Check `package.json` scripts — `wrangler deploy` without `pages` → Workers. `wrangler pages deploy` → Pages.
3. Check the framework — Next.js, Astro, Remix, SvelteKit, Nuxt → Pages with framework adapter. Express/Hono/Fastify → Workers.

---

## 3. Pre-Deploy Checklist

Before deploying, verify these in order:

| Step | Check | Command |
|------|-------|---------|
| **Credentials** | Is `wrangler` authenticated? | `npx wrangler whoami` |
| **Config valid** | Is `wrangler.toml`/`wrangler.jsonc` valid? | `npx wrangler deploy --dry-run` (Workers) or read the config file for syntax errors |
| **Secrets ready** | Are all required secrets set? | `npx wrangler secret list` (Workers) or `npx wrangler pages secret list --project <name>` (Pages) |
| **Build** | Does the project build? | `{{BUILD_CMD}}` |

**If credentials fail**: guide the user to get a Cloudflare API Token at
[dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens)
with these permissions:
- `Account.Workers Scripts:Edit`
- `Account.Cloudflare Pages:Edit` (for Pages)

Then run `npx wrangler login` or set `CLOUDFLARE_API_TOKEN` env var.

**If secrets are missing**: compare `npx wrangler secret list` output with what the
app expects (check `.env.example`, `.env`, or `wrangler.jsonc` `vars`). Guide user
to run `npx wrangler secret put <NAME>` for each missing secret.

---

## 4. Setup (if no config exists)

### Workers setup:
```bash
npx wrangler init --yes
```

Then edit `wrangler.jsonc`:
```jsonc
{
  "$schema": "https://raw.githubusercontent.com/cloudflare/workers-sdk/main/packages/wrangler/config-schema.json",
  "name": "my-worker",
  "main": "src/index.ts",
  "compatibility_date": "2025-06-01",
  "compatibility_flags": ["nodejs_compat"],
  "vars": {
    "ENVIRONMENT": "production"
  }
}
```

### Pages setup (framework):
```bash
npx wrangler pages project create <project-name> --production-branch main
```

### Pages setup (static HTML):
No special config needed. Just have an output folder (e.g. `dist/`).

---

## 5. Secrets & Environment Variables

**Key difference:**
- **`vars`** in `wrangler.jsonc` — non-sensitive, committed to git. Example: `ENVIRONMENT`, `API_URL`.
- **Secrets** — sensitive, encrypted at rest in Cloudflare. Example: `DATABASE_URL`, `API_KEY`.

### Set a secret:
```bash
npx wrangler secret put DATABASE_URL
# (paste value, press Enter)
```

### List existing secrets:
```bash
npx wrangler secret list
```

### For Pages:
```bash
npx wrangler pages secret put DATABASE_URL --project <project-name>
```

---

## 6. Build

```bash
{{BUILD_CMD}}
```

If `{{BUILD_CMD}}` is not set, auto-detect:
- `package.json` scripts: check `"build"` → `npm run build`
- Next.js → `npx next build`
- Astro → `npx astro build`
- Vite → `npx vite build`

---

## 7. Deploy

### Workers:
```bash
npx wrangler deploy
```

### Pages (static / framework):
```bash
npx wrangler pages deploy <output-dir> --project-name <project-name> --branch {{MAIN_BRANCH}}
```

Output dir auto-detection:
- Next.js: `.vercel/output/static` or `.next`
- Astro: `dist`
- SvelteKit: `build`
- Remix: `build/client`
- Vite: `dist`
- Manual: check `pages_build_output_dir` in `wrangler.toml`/`wrangler.jsonc`

### Pages via git (CI-based):
If the repo is connected to Cloudflare Pages via git, just push to `{{MAIN_BRANCH}}` —
Cloudflare auto-deploys.

---

## 8. Post-Deploy Verification

### Workers:
```bash
# Check worker status
npx wrangler deployments list

# Test endpoint (replace URL)
curl -I https://my-worker.<subdomain>.workers.dev

# Tail logs (real-time, 2 minutes)
npx wrangler tail --format pretty
```

### Pages:
```bash
# Check latest deployment
npx wrangler pages deployment list --project <project-name>

# Open in browser (if available)
npx wrangler pages deployment show --project <project-name> --open
```

### Report to user:
- Production URL: `https://<project>.<subdomain>.workers.dev` (Workers) or `https://<project>.pages.dev` (Pages)
- Deployment ID
- Deploy time
- If custom domain is needed, guide to [dash.cloudflare.com](https://dash.cloudflare.com) → Workers & Pages → project → Custom Domains

---

## 9. Rollback

### Workers:
```bash
# View deployment history
npx wrangler deployments list

# Rollback to previous deployment
npx wrangler rollback --deployment-id <id>
```

### Pages:
```bash
npx wrangler pages deployment rollback --project <project-name>
```

---

## 10. Common Gotchas

- **`nodejs_compat`**: Many npm packages need this. Add `"nodejs_compat"` to `compatibility_flags` in `wrangler.jsonc`.
- **Free tier limits**: Workers: 100k requests/day, 10ms CPU/request. Pages: 500 builds/month, 1 concurrent build. Production scale needs Workers Paid ($5/month).
- **Cold starts**: Workers can cold-start. Pages static files are nearly instant.
- **Environment variables vs Secrets**: Never put secrets in `vars` — they get committed to git. Use `wrangler secret put`.
- **Multiple environments**: For staging, use `--env staging`. Edit the `[env.staging]` section in `wrangler.toml`.
- **Custom domain**: Workers: `workers.dev` subdomain is automatic. Pages: `pages.dev` subdomain is automatic. Custom domains need DNS setup in the Cloudflare dashboard.
