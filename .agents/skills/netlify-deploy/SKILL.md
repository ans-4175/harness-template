# Netlify Deploy

Deploy to Netlify for static sites, serverless functions, and form handling.
Very simple — ideal for beginners. Generous free tier.

---

## 1. Detection

The project uses Netlify if:
- `netlify.toml` in the root
- `"netlify"` in `devDependencies`/`dependencies` in `package.json`
- `"netlify"` in deploy script in `package.json`
- `.netlify/` folder exists

---

## 2. Determine project type

| Trait | Static Site | Serverless Functions |
|-------|-------------|---------------------|
| Framework | HTML, Vite, React SPA, Vue, Svelte | Next.js API routes, Express-like |
| Config | `netlify.toml` with `publish` dir | `netlify.toml` with `functions` dir |
| Deploy | `netlify deploy --prod --dir=dist` | Same, auto-detects functions |

---

## 3. Pre-Deploy Checklist

Before deploying, verify these in order:

| Step | Check | Command |
|------|-------|---------|
| **Credentials** | Is Netlify CLI authenticated? | `netlify status` |
| **Config valid** | Is `netlify.toml` valid? (if exists) | Read the file and validate TOML syntax |
| **Secrets ready** | Are all required env vars set? | `netlify env:list` |
| **Build** | Does the project build? | `{{BUILD_CMD}}` |

**If credentials fail**: guide the user to run `netlify login` — this opens a browser
for GitHub/GitLab/Bitbucket/email authorization. Alternatively, they can create a
personal access token at [app.netlify.com/user/applications](https://app.netlify.com/user/applications).

**If secrets are missing**: compare `netlify env:list` output with what the app expects
(check `.env.example` or `.env`). Guide user to run `netlify env:set <NAME> "<value>"`
for each missing variable. For different contexts: `--context production|deploy-preview|branch-deploy|dev`.

---

## 4. Setup (if no config exists)

### Install CLI:
```bash
npm i -g netlify-cli
```

### Login:
```bash
netlify login
```
Opens a browser. Authorize via GitHub/GitLab/Bitbucket/email.

### Init project (from project root):
```bash
netlify init
```
The CLI will:
1. Connect to Netlify account
2. Select team
3. Create a new site or connect existing
4. Auto-detect build command & publish directory

### Minimal `netlify.toml` (for static site):
```toml
[build]
  command = "npm run build"
  publish = "dist"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```
The SPA redirect is essential for single-page apps (React Router, Vue Router).

### `netlify.toml` for API (serverless functions):
```toml
[build]
  command = "npm run build"
  publish = "dist"
  functions = "netlify/functions"

[[redirects]]
  from = "/api/*"
  to = "/.netlify/functions/:splat"
  status = 200
```

---

## 5. Secrets & Environment Variables

### Set via CLI:
```bash
netlify env:set DATABASE_URL "postgres://..."
```

### Import from `.env` file:
```bash
netlify env:import .env
```

### Set for a specific context:
```bash
netlify env:set DATABASE_URL "value" --context production
```
Contexts: `production`, `deploy-preview`, `branch-deploy`, `dev`.

### Check existing:
```bash
netlify env:list
```

### UI:
Also available at [app.netlify.com](https://app.netlify.com) → Site → Site settings → Environment variables.

---

## 6. Build

```bash
{{BUILD_CMD}}
```

Netlify auto-builds popular frameworks, but for manual deploy, build locally first.

---

## 7. Deploy

### Manual deploy (via CLI):
```bash
# Preview deploy (draft URL)
netlify deploy --dir=dist

# Production deploy
netlify deploy --prod --dir=dist
```

### Deploy via git (CI-based):
If the repo is connected to Netlify via git, just push to `{{MAIN_BRANCH}}` —
Netlify auto-builds & deploys.

### Deploy specific functions only:
```bash
netlify deploy --functions=netlify/functions
```

---

## 8. Post-Deploy Verification

```bash
# View site info
netlify status

# Open in browser
netlify open:site

# View deploy log
netlify deploy:list

# Check functions log
netlify functions:list
```

### Report to user:
- Site URL: `https://<site-name>.netlify.app`
- Site ID & admin URL: `https://app.netlify.com/sites/<site-name>`
- For custom domain: `https://app.netlify.com/sites/<site-name>/settings/domain`

---

## 9. Rollback

```bash
# View deployment history
netlify deploy:list

# Rollback (interactive — select deployment)
netlify rollback
```

Or via UI: [app.netlify.com](https://app.netlify.com) → Site → Deploys → select deployment → "Publish deploy".

---

## 10. Common Gotchas

- **SPA redirects**: Single-page apps MUST have a redirect `/* → /index.html` (status 200). Without this, refreshing on a sub-route returns 404.
- **Functions runtime**: Defaults to Node.js. Set `AWS_LAMBDA_JS_RUNTIME` env var or use `.nvmrc` for specific versions.
- **Functions timeout**: 10 seconds max (same as AWS Lambda). For longer tasks, consider Cloudflare Workers or Fly.io.
- **Build minutes**: Free tier 300 minutes/month. Enough for personal/small projects.
- **Bandwidth**: Free tier 100 GB/month.
- **Forms**: Netlify auto-detects HTML forms (`<form netlify>`). No backend needed — submissions appear in the dashboard.
