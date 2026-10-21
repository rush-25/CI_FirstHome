# FirstHome Nigeria — Vercel Deployment Guide

This guide provides step-by-step instructions for hosting the **FirstHome Nigeria** Flutter Web frontend on **Vercel**.

---

## Architecture Overview

- **Frontend (Flutter Web)**: Hosted on Vercel's global Edge CDN with SPA routing and asset caching.
- **Backend (.NET 9 Web API)**: Hosted on a backend container/VM service (such as Render, Railway, Azure, or Fly.io).
- **Connecting Both**: Configured through the `API_BASE_URL` environment variable.

---

## Option 1: Deploy Directly via Terminal (Fastest — 2 Minutes)

You can deploy the pre-built web application straight to Vercel right from your computer without configuring Git webhooks.

### Step 1: Build the Web App
From the `frontend` folder:
```bash
cd frontend
flutter build web --release
```
*(If you have a live backend URL, add `--dart-define=API_BASE_URL=https://your-api.com/api`)*

### Step 2: Deploy to Vercel
Run Vercel CLI via `npx` (no global installation needed):
```bash
npx vercel --prod
```

1. It will ask: `Set up and deploy?` &rarr; Enter `Y`
2. `Which scope?` &rarr; Select your Vercel account
3. `Link to existing project?` &rarr; Enter `N` (or `Y` if updating an existing project)
4. `What's your project's name?` &rarr; `firsthome-nigeria` (or press Enter)
5. `In which directory is your code located?` &rarr; Press Enter (`./`)
6. Vercel will upload and provide your live URL (e.g. `https://firsthome-nigeria.vercel.app`)!

---

## Option 2: Connect GitHub to Vercel (Automatic Deployments on Git Push)

The repository is already pre-configured with `vercel.json`, `vercel-build.sh`, and `package.json`.

### Step 1: Push changes to GitHub
```bash
git add .
git commit -m "Configure Vercel deployment and routing"
git push origin main
```

### Step 2: Import on Vercel
1. Log in to [vercel.com](https://vercel.com).
2. Click **Add New...** &rarr; **Project**.
3. Select your repository: `rush-25/CI_FirstHome`.
4. In the **Project Settings**:
   - **Root Directory**: Select `frontend` (or leave default `./` — both are supported!).
   - **Framework Preset**: Leave as **Other**.
   - **Build Command**: `bash vercel-build.sh` (already configured in `package.json`).
   - **Output Directory**: `build/web` (or `frontend/build/web` if root).
5. **Environment Variables** (Optional):
   - Key: `API_BASE_URL`
   - Value: `https://your-backend-api.com/api`
6. Click **Deploy**. Vercel will automatically run the build script and host your site!

---

## Option 3: GitHub Actions CI/CD to Vercel

A complete workflow file has been created at [`.github/workflows/deploy-vercel.yml`](.github/workflows/deploy-vercel.yml).

To use this:
1. In your GitHub repository settings, go to **Settings** &rarr; **Secrets and variables** &rarr; **Actions**.
2. Add the following secrets from your Vercel Account:
   - `VERCEL_TOKEN`: Generated from [vercel.com/account/tokens](https://vercel.com/account/tokens)
   - `VERCEL_ORG_ID`: Found in `.vercel/project.json` or your Team Settings
   - `VERCEL_PROJECT_ID`: Found in `.vercel/project.json` or Project Settings
   - `API_BASE_URL`: (Optional) Your production API base URL
3. Every push to the `main` branch will automatically build and deploy the latest web app to Vercel.

---

## Key Configurations Included in this Setup

1. **SPA Route Handling (`vercel.json`)**:
   - When users refresh pages or visit deep routes directly (e.g., `/directory`, `/customer-dashboard`, `/provider-dashboard`), Vercel rewrites the request to `index.html` so Flutter Web's router handles it seamlessly without returning HTTP 404 errors.
2. **Browser Back Navigation**:
   - The app uses native `MaterialApp` named routing and `window.history`, ensuring standard browser Back, Forward, and swipe gestures work flawlessly in production.
3. **Optimized Caching**:
   - CanvasKit and static font assets are cached with immutable headers for instant reloads.
   - Core JavaScript files (`flutter_bootstrap.js`, `main.dart.js`) have revalidation rules to guarantee users always receive the latest release.
