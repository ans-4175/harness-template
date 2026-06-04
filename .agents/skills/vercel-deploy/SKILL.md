# Vercel Deploy

Deploy to Vercel for static sites, serverless functions, and full-stack frameworks
(Next.js, SvelteKit, Astro, Nuxt, Remix). Designed for beginners.

---

## 1. Detection

The project uses Vercel if any of these exist:
- `vercel.json` in the root
- `"vercel"` in `devDependencies`/`dependencies` in `package.json`
- `"deploy"` script in `package.json` contains `vercel`
- `.vercel/` folder exists (after a previous deploy)

---

## 2. Determine project type

| Trait | Static | Serverless | Full-stack Framework |
|-------|--------|------------|---------------------|
| Framework | Plain HTML, Vite SPA | Express, Hono, Fastify, plain functions | Next.js, SvelteKit, Astro, Nuxt, Remix |
| Config needed | Minimal | `vercel.json` with `functions` | Usually auto-detected |
| Build output | `dist/`, `out/` | `api/` folder | Framework build dir |

---

## 3. Pre-Deploy Checklist

Before deploying, verify these in order:

| Step | Check | Command |
|------|-------|---------|
| **Credentials** | Is Vercel CLI authenticated? | `vercel whoami` |
| **Config valid** | Is `vercel.json` valid? (if exists) | `vercel inspect` or read the file and validate JSON syntax |
| **Secrets ready** | Are all required env vars set? | `vercel env ls` |
| **Build** | Does the project build? | `{{BUILD_CMD}}` |

**If credentials fail**: guide the user to run `vercel login` — this opens a browser for
GitHub/GitLab/Bitbucket/email login. Alternatively, they can create a token at
[vercel.com/account/tokens](https://vercel.com/account/tokens).

**If secrets are missing**: compare `vercel env ls` output with what the app expects
(check `.env.example` or `.env`). Guide user to run `vercel env add <NAME> production`
for each missing variable.

---

## 4. Setup (if no config exists)

### Install CLI:
```bash
npm i -g vercel
```

### Login:
```bash
vercel login
```
This opens a browser. User logs in with GitHub/GitLab/Bitbucket/email.

### Init project (from project root):
```bash
vercel
```
Vercel CLI asks a few questions and auto-detects the framework.

### Minimal `vercel.json` (for static site):
```json
{
  "outputDirectory": "dist"
}
```

### `vercel.json` for API (serverless functions):
```json
{
  "functions": {
    "api/*.js": {
      "runtime": "@vercel/node@3"
    }
  }
}
```

---

## 5. Secrets & Environment Variables

### Set via dashboard:
1. Go to [vercel.com/dashboard](https://vercel.com/dashboard)
2. Select project → Settings → Environment Variables
3. Add variable (production, preview, development)

### Set via CLI:
```bash
vercel env add DATABASE_URL production
# (paste value)
```

### Check existing:
```bash
vercel env ls
```

---

## 6. Build

```bash
{{BUILD_CMD}}
```

Vercel auto-builds popular frameworks (Next.js, etc.), but for static/manual projects,
make sure the build passes locally first.

---

## 7. Deploy

### Preview deploy (not production):
```bash
vercel
```
Deploys to a preview URL (e.g. `my-project-abc123.vercel.app`). Good for testing first.

### Production deploy:
```bash
vercel --prod
```
Deploys to the production URL (aliased to custom domain if set).

### Deploy via git (CI-based):
If the repo is connected to Vercel via git, just push to `{{MAIN_BRANCH}}` —
Vercel auto-deploys.

---

## 8. Post-Deploy Verification

```bash
# View latest deployments
vercel ls

# View logs for a specific deployment
vercel logs <deployment-url>

# Alias to custom domain (if needed)
vercel alias <deployment-url> <custom-domain>
```

### Report to user:
- Preview URL (if preview deploy)
- Production URL: `https://<project>.vercel.app` or custom domain
- If custom domain is not set, guide to [vercel.com/dashboard](https://vercel.com/dashboard) → project → Settings → Domains

---

## 9. Rollback

```bash
# View deployment history
vercel ls <project-name>

# Rollback to previous deployment (interactive prompt)
vercel rollback
```

Or via dashboard: project → Deployments → select deployment → "Promote to Production"

---

## 10. Common Gotchas

- **Free tier**: 100 GB bandwidth/month, 6000 build minutes/month. Plenty for personal/small projects.
- **Serverless function timeout**: Max 10 seconds (Hobby), 60 seconds (Pro). For longer tasks, consider Cloudflare Workers.
- **Environment variables**: Preview deploys use env vars set for "Preview", not "Production". Make sure env vars are set in the right environment.
- **Build cache**: Don't gitignore `.vercel` if you need caching between deploys.
- **Monorepo**: If inside a monorepo, set `"buildCommand"` and `"outputDirectory"` in `vercel.json` to the correct subfolder.
- **Node.js version**: Set in `package.json` `engines.node` or in dashboard Settings → General → Node.js Version.
