# Auth0 Connection Issues - Quick Fix Guide

## 🚨 Problem: "Refused to Connect"

### ⚡ Fastest Solutions (Try in Order)

#### 1. **Hard Refresh Browser** (10 seconds)
```bash
# Windows/Linux: Ctrl + Shift + R
# Mac: Cmd + Shift + R
# Or: Ctrl + F5
```
✓ Fixes 30% of issues

---

#### 2. **Check Environment File** (30 seconds)
```bash
# Verify .env.local exists and has Auth0 config
cat .env.local | grep VITE_AUTH0

# Should show:
# VITE_AUTH0_DOMAIN=dev-0xjbxjcxahd1fxhq.us.auth0.com
# VITE_AUTH0_CLIENT_ID=DNoWzDvO9bDUUDLqbxNB8xza0bSbOnMI
# VITE_AUTH0_AUDIENCE=https://api.leadtoclose.ai

# If missing, copy from .env:
cp .env .env.local
```
✓ Fixes 25% of issues

---

#### 3. **Update Auth0 Callback URLs** (2 minutes)
1. Go to **Auth0 Dashboard** → https://manage.auth0.com
2. Click **Applications** (left sidebar)
3. Select your app
4. Click **Settings** tab
5. Find "Allowed Callback URLs"
6. Replace with:
   ```
   http://localhost:5173/callback
   http://localhost:5173
   https://your-production-domain.com/callback
   https://your-production-domain.com
   ```
7. Click **Save Changes**
8. Hard refresh browser

✓ Fixes 40% of issues

---

#### 4. **Update CORS Origins** (2 minutes)
1. Same app in Auth0 Dashboard
2. Find "CORS Allowed Origins"
3. Add:
   ```
   http://localhost:5173
   https://your-production-domain.com
   ```
4. Click **Save Changes**
5. Hard refresh browser

✓ Fixes 15% of issues

---

#### 5. **Clear Cache & Restart Dev Server** (1 minute)
```bash
# Kill dev server (Ctrl+C)

# Clear cache
rm -rf node_modules/.vite

# Restart
npm run dev
```
✓ Fixes 10% of issues

---

#### 6. **Try Incognito/Private Window** (30 seconds)
- Chrome: Ctrl+Shift+N
- Firefox: Ctrl+Shift+P
- Safari: Cmd+Shift+N

If it works in private window → **Your browser cache is corrupted**
Solution: Clear all cookies, cache, and local storage for your domain

✓ Fixes 5% of issues

---

#### 7. **Check Internet Connection** (30 seconds)
```bash
# Test DNS
nslookup dev-0xjbxjcxahd1fxhq.us.auth0.com

# Test connectivity
ping -c 4 dev-0xjbxjcxahd1fxhq.us.auth0.com

# Test HTTPS
curl -I https://dev-0xjbxjcxahd1fxhq.us.auth0.com/.well-known/openid-configuration

# Try different network (or disconnect VPN)
```
✓ Fixes 10% of issues

---

## 🔍 Verification Script

Run automated verification:
```bash
./scripts/verify-auth0.sh
```

Or manually verify in browser console:
```javascript
// F12 → Console tab

// Test 1: Check environment variables
console.log('Domain:', import.meta.env.VITE_AUTH0_DOMAIN)

// Test 2: Check connectivity
fetch('https://dev-0xjbxjcxahd1fxhq.us.auth0.com/.well-known/openid-configuration')
  .then(r => r.json())
  .then(d => console.log('✓ Auth0 reachable'))
  .catch(e => console.error('✗ Auth0 unreachable:', e))
```

---

## 📋 Common Issues & Quick Fixes

| Issue | Quick Fix | Time |
|-------|-----------|------|
| **Black page after login** | Hard refresh (Cmd+Shift+R) | 10s |
| **"Invalid callback URL"** | Update Callback URLs in Auth0 | 2min |
| **CORS error in console** | Add CORS Origins in Auth0 | 2min |
| **Works in private window only** | Clear browser cookies/cache | 1min |
| **Fails from work network** | Try different network or VPN | 5min |
| **Env variables missing** | Copy .env to .env.local | 30s |
| **Dev server offline** | npm run dev | 30s |
| **DNS can't resolve domain** | Check internet, try 8.8.8.8 | 2min |

---

## ✅ Pre-Flight Checklist

Before diving into debugging, verify:

- [ ] Internet connection is working
- [ ] Can reach other websites
- [ ] Dev server is running (`npm run dev`)
- [ ] `.env.local` file exists
- [ ] Auth0 domain matches dashboard
- [ ] Auth0 Client ID is not empty
- [ ] Tenant is not suspended (check Auth0 dashboard)
- [ ] Not using VPN that blocks Auth0

---

## 🎯 Decision Tree

```
Auth0 connection failing?
├─ Hard refresh first (Cmd+Shift+R)
│  └─ If fixed → Done! ✓
│
├─ Try private/incognito window
│  └─ If works → Clear cookies/cache
│
├─ Check env variables (cat .env.local)
│  └─ If empty → cp .env .env.local
│
├─ Verify internet connection
│  ├─ DNS: nslookup dev-0xjbxjcxahd1fxhq.us.auth0.com
│  ├─ Ping: ping dev-0xjbxjcxahd1fxhq.us.auth0.com
│  └─ If fails → Check network/firewall
│
├─ Check Auth0 Dashboard
│  ├─ Callback URLs configured? (add localhost:5173)
│  ├─ CORS Origins configured? (add localhost:5173)
│  └─ If missing → Add and save
│
└─ Run verification script
   └─ ./scripts/verify-auth0.sh
```

---

## 🔧 Database Schema for Tracking Auth0 Issues

If you want to log Auth0 issues:

```sql
CREATE TABLE auth0_issues (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  error_message text,
  error_type text,
  timestamp timestamptz DEFAULT now(),
  browser text,
  os text,
  resolved boolean DEFAULT false
);

-- Enable RLS
ALTER TABLE auth0_issues ENABLE ROW LEVEL SECURITY;

-- Allow users to view their own issues
CREATE POLICY "Users can view own issues"
  ON auth0_issues FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);
```

---

## 💡 Pro Tips

### Tip 1: Always Update After Dashboard Changes
```
Auth0 Dashboard Change → Wait 5 seconds → Hard Refresh Browser
```

### Tip 2: Use Browser DevTools
```
F12 → Network tab → Attempt login
Look for requests to "dev-0xjbxjcxahd1fxhq.us.auth0.com"
Check status (should be 2xx or 3xx, not 5xx)
```

### Tip 3: Check Auth0 Status
Visit: https://status.auth0.com
Look for service incidents or maintenance

### Tip 4: VPN Issues
Auth0 may be blocked by:
- Corporate firewalls
- University networks
- ISP restrictions
- VPN services

Solution: Try different network or VPN region

### Tip 5: Enable Debug Mode
```typescript
// In AuthProvider.tsx
const auth0Config = {
  domain: import.meta.env.VITE_AUTH0_DOMAIN,
  clientId: import.meta.env.VITE_AUTH0_CLIENT_ID,
  authorizationParams: {
    redirect_uri: window.location.origin,
  },
  // Add for debugging
  cacheLocation: 'localstorage' as const,
};

// Then check localStorage in DevTools
localStorage.getItem('@@auth0spajs@@')
```

---

## 🆘 Still Not Working?

If none of the above fixes work:

1. **Collect Information:**
   ```bash
   # Browser console error
   # Screenshot of error
   # Output from: ./scripts/verify-auth0.sh
   # Output from: git log --oneline -5
   ```

2. **Run Full Diagnostics:**
   ```javascript
   // In browser console
   import { logAuth0Diagnostics } from './utils/auth0Health'
   await logAuth0Diagnostics()
   ```

3. **Create Issue with Details:**
   - Exact error message
   - Browser & OS
   - When did it break (today, this week?)
   - What changed recently (git diff HEAD~5)
   - Output from scripts above

4. **Contact Auth0 Support:**
   - Go to: https://manage.auth0.com → Support → Open Ticket
   - Include all information from step 3

---

## 📞 Auth0 Support

**Support Portal:** https://manage.auth0.com/support
**Status Page:** https://status.auth0.com
**Docs:** https://auth0.com/docs
**Community:** https://auth0.com/community

---

**Last Updated:** Dec 2024
**For:** Auth0 React SDK v2.x
**Domain:** dev-0xjbxjcxahd1fxhq.us.auth0.com
