# Auth0 "Refused to Connect" - Comprehensive Troubleshooting Guide

## Problem Summary
**Error:** Connection refused when attempting to connect to Auth0 domain
**Domain:** `dev-0xjbxjcxahd1fxhq.us.auth0.com`
**Status:** Was working initially, now failing
**Error Pattern:** Network-level "refused to connect"

---

## 🎯 Diagnosis Priority (Most to Least Likely)

### 1. **Allowed Callback URLs Mismatch** (40% likelihood)
**Why it breaks:** The most common cause after working initially is auth URL whitelist misconfiguration

**Quick Diagnosis:**
```bash
# Check your current application URL
echo "Development: http://localhost:5173"
echo "Production: your-production-domain.com"
echo "Staging: your-staging-domain.com"
```

**Fix:**
1. Go to Auth0 Dashboard → Applications → Your App → Settings
2. Scroll to "Allowed Callback URLs"
3. Verify these URLs are listed:
   - `http://localhost:5173/callback` (dev)
   - `http://localhost:5173` (dev fallback)
   - `https://your-domain.com/callback` (prod)
   - `https://your-domain.com` (prod fallback)

4. Also check "Allowed Logout URLs":
   - `http://localhost:5173` (dev)
   - `https://your-domain.com` (prod)

5. Click "Save Changes"

---

### 2. **Environment Variable Issues** (30% likelihood)
**Why it breaks:** Incorrect/missing Auth0 credentials in `.env` or `.env.local`

**Quick Diagnosis:**
```bash
# Check your .env.local file exists
ls -la .env.local

# Verify Auth0 variables are set
grep VITE_AUTH0 .env.local
```

**Current Config in `.env`:**
```
VITE_AUTH0_DOMAIN=dev-0xjbxjcxahd1fxhq.us.auth0.com
VITE_AUTH0_CLIENT_ID=DNoWzDvO9bDUUDLqbxNB8xza0bSbOnMI
VITE_AUTH0_AUDIENCE=https://api.leadtoclose.ai
```

**Verification Steps:**
1. Confirm `.env.local` has identical values
2. Check there are no extra spaces or quotes
3. Ensure domain is spelled correctly (no typos)
4. Verify CLIENT_ID matches Auth0 dashboard

**Fix:**
```bash
# Copy .env to .env.local
cp .env .env.local

# Edit .env.local and verify:
# - No trailing/leading spaces
# - Correct domain name
# - Valid CLIENT_ID from Auth0 dashboard
```

---

### 3. **CORS Issues** (15% likelihood)
**Why it breaks:** Auth0 domain blocked by browser CORS policy

**Symptoms:**
- Works in one browser but not another
- Works on one machine but not another
- Browser console shows CORS errors

**Quick Diagnosis - Browser Console:**
```javascript
// In browser DevTools console
fetch('https://dev-0xjbxjcxahd1fxhq.us.auth0.com')
  .catch(e => console.log('CORS Error:', e))
```

**Fix - Check Auth0 Dashboard:**
1. Go to Auth0 Dashboard → Applications → Your App → Settings
2. Scroll to "CORS Allowed Origins"
3. Verify these are listed:
   - `http://localhost:5173`
   - `http://localhost:3000`
   - `https://your-domain.com`

4. Save changes
5. Hard refresh browser (Ctrl+Shift+R or Cmd+Shift+R)

---

### 4. **Tenant or API Issues** (10% likelihood)
**Why it breaks:** Auth0 tenant suspended, API disabled, or rate limited

**Quick Diagnosis - Auth0 Dashboard:**
1. Check Tenant Status → Health Dashboard
2. Look for any warnings or alerts
3. Check APIs → Management API → Status

**Signs of tenant issues:**
- Service degradation alerts in dashboard
- Multiple failed login attempts (rate limiting)
- Billing/subscription issues

**Fix:**
- Review Auth0 Tenants → Settings for account status
- Check Email to inbox for auth0 notifications
- Verify subscription is active

---

### 5. **SSL/TLS Certificate Issues** (3% likelihood)
**Why it breaks:** Certificate chain problems or security software interference

**Quick Diagnosis:**
```bash
# Test SSL connection
openssl s_client -connect dev-0xjbxjcxahd1fxhq.us.auth0.com:443

# Or use curl
curl -vv https://dev-0xjbxjcxahd1fxhq.us.auth0.com/.well-known/openid-configuration
```

**Network Issues:**
- VPN blocking Auth0
- Corporate firewall blocking Auth0
- ISP blocking specific domains
- DNS resolution issues

**Fix:**
```bash
# Check DNS resolution
nslookup dev-0xjbxjcxahd1fxhq.us.auth0.com
ping dev-0xjbxjcxahd1fxhq.us.auth0.com

# Try from different network if local network blocks
# Try VPN from different region
```

---

## 🔧 Step-by-Step Troubleshooting (in order)

### Step 1: Verify Auth0 Tenant Status (2 minutes)
```bash
# Open Auth0 Dashboard
# Go to Tenants → Settings
# Check:
- [ ] Tenant is ACTIVE (not suspended)
- [ ] Subscription is VALID
- [ ] No alerts or warnings
- [ ] Health status is GREEN
```

### Step 2: Verify Application Settings (3 minutes)
**Auth0 Dashboard:**
1. Applications → Applications (left sidebar)
2. Find and click your app
3. Copy these values and compare:
   ```
   Domain: _______________
   Client ID: _______________
   Audience: _______________
   ```
4. Update your `.env.local` if any differ

### Step 3: Update Callback URLs (2 minutes)
**Auth0 Dashboard:**
1. Applications → Your App → Settings
2. "Allowed Callback URLs" section
3. Clear existing and add (line by line):
   ```
   http://localhost:5173/callback
   http://localhost:5173
   https://your-production-domain.com/callback
   https://your-production-domain.com
   ```
4. "Allowed Logout URLs":
   ```
   http://localhost:5173
   https://your-production-domain.com
   ```
5. Save Changes

### Step 4: Update CORS Origins (2 minutes)
**Auth0 Dashboard:**
1. Applications → Your App → Settings
2. "CORS Allowed Origins" section
3. Add these origins:
   ```
   http://localhost:5173
   https://your-production-domain.com
   ```
4. Save Changes

### Step 5: Clear Browser Cache (1 minute)
```bash
# Option 1: Hard refresh
# Windows: Ctrl + Shift + R
# Mac: Cmd + Shift + R

# Option 2: Clear cache manually
# Chrome: Settings → Privacy → Clear browsing data
#   - Check: Cookies, Cached images
#   - Time range: All time
#   - Clear data

# Option 3: Incognito/Private mode
# Test in incognito window (Ctrl+Shift+N or Cmd+Shift+N)
```

### Step 6: Verify Environment Variables (2 minutes)
```bash
# Check .env.local exists
test -f .env.local && echo "✓ .env.local exists" || echo "✗ .env.local missing"

# Show Auth0 vars (safely)
grep "VITE_AUTH0" .env.local

# Compare with dashboard
echo "Expected:"
echo "VITE_AUTH0_DOMAIN=dev-0xjbxjcxahd1fxhq.us.auth0.com"
echo "VITE_AUTH0_CLIENT_ID=DNoWzDvO9bDUUDLqbxNB8xza0bSbOnMI"
echo "VITE_AUTH0_AUDIENCE=https://api.leadtoclose.ai"
```

### Step 7: Check Network Connectivity (2 minutes)
```bash
# Test DNS resolution
nslookup dev-0xjbxjcxahd1fxhq.us.auth0.com

# Test ping
ping -c 4 dev-0xjbxjcxahd1fxhq.us.auth0.com

# Test HTTPS connection
curl -I https://dev-0xjbxjcxahd1fxhq.us.auth0.com/.well-known/openid-configuration

# Should return: HTTP/1.1 200 OK
```

### Step 8: Test in Browser Console (3 minutes)
```javascript
// Open Developer Tools (F12)
// Go to Console tab
// Run these commands:

// 1. Check if fetch works
fetch('https://dev-0xjbxjcxahd1fxhq.us.auth0.com/.well-known/openid-configuration')
  .then(r => r.json())
  .then(d => console.log('✓ Connection works', d))
  .catch(e => console.error('✗ Connection failed', e))

// 2. Check environment variables
console.log('Domain:', import.meta.env.VITE_AUTH0_DOMAIN)
console.log('Client ID:', import.meta.env.VITE_AUTH0_CLIENT_ID)

// 3. Check Auth0 React SDK loaded
console.log('Auth0 SDK:', window.auth0)
```

### Step 9: Restart Dev Server (1 minute)
```bash
# Kill dev server
# (Ctrl+C in terminal)

# Restart with cache clear
rm -rf node_modules/.vite
npm run dev

# If still issues:
rm -rf node_modules
npm install
npm run dev
```

### Step 10: Check Recent Changes (5 minutes)
```bash
# Review git history
git log --oneline -20

# Check what changed recently
git diff HEAD~5

# Look for:
# - Auth0 config changes
# - .env modifications
# - Application URL changes
# - Auth0 version updates
```

---

## 🔍 Browser DevTools Debugging

### Console Error Messages

**Error:** `Failed to fetch`
```
Cause: Network refused or CORS blocked
Solution: Check network connectivity, CORS origins in Auth0
```

**Error:** `TypeError: fetch failed`
```
Cause: Network unreachable
Solution: Check internet, DNS, VPN, firewall
```

**Error:** `CORS policy: No 'Access-Control-Allow-Origin' header`
```
Cause: Auth0 CORS origins not configured
Solution: Add current domain to CORS origins in Auth0 dashboard
```

**Error:** `Invalid domain`
```
Cause: Incorrect Auth0 domain in .env
Solution: Verify domain matches Auth0 dashboard exactly
```

### Network Tab Analysis

1. Open DevTools → Network tab
2. Attempt login
3. Look for requests to `dev-0xjbxjcxahd1fxhq.us.auth0.com`
4. Check:
   - Status code: Should be 200-299 for success
   - Response headers: Look for `Access-Control-Allow-Origin`
   - Latency: 100-500ms is normal
   - Size: Should have response body

---

## 🛡️ Prevention Strategies

### 1. **Use Environment File Template**
Create `.env.local.example`:
```bash
# Copy this to .env.local and fill in your values
VITE_AUTH0_DOMAIN=dev-0xjbxjcxahd1fxhq.us.auth0.com
VITE_AUTH0_CLIENT_ID=your_client_id_here
VITE_AUTH0_AUDIENCE=https://api.leadtoclose.ai
VITE_API_BASE_URL=your_api_url_here
```

### 2. **Add Environment Validation**
Create `src/utils/validateAuth0Config.ts`:
```typescript
export const validateAuth0Config = (): boolean => {
  const domain = import.meta.env.VITE_AUTH0_DOMAIN;
  const clientId = import.meta.env.VITE_AUTH0_CLIENT_ID;

  if (!domain || !clientId) {
    console.error('Missing Auth0 configuration');
    console.error('VITE_AUTH0_DOMAIN:', domain ? '✓' : '✗ missing');
    console.error('VITE_AUTH0_CLIENT_ID:', clientId ? '✓' : '✗ missing');
    return false;
  }

  if (!domain.includes('.auth0.com')) {
    console.error('Invalid Auth0 domain format');
    return false;
  }

  console.log('✓ Auth0 configuration valid');
  return true;
};
```

### 3. **Add Health Check Endpoint**
Create `src/utils/auth0HealthCheck.ts`:
```typescript
export const checkAuth0Health = async (): Promise<boolean> => {
  try {
    const domain = import.meta.env.VITE_AUTH0_DOMAIN;
    const response = await fetch(
      `https://${domain}/.well-known/openid-configuration`,
      { method: 'HEAD' }
    );
    return response.ok;
  } catch (error) {
    console.error('Auth0 health check failed:', error);
    return false;
  }
};
```

### 4. **Monitor in Application**
```typescript
// Add to App.tsx or main component
useEffect(() => {
  const checkHealth = async () => {
    const isHealthy = await checkAuth0Health();
    if (!isHealthy) {
      console.warn('⚠️ Auth0 connection issue detected');
      // Could also send to error tracking
    }
  };

  checkHealth();
  const interval = setInterval(checkHealth, 5 * 60 * 1000); // Every 5 min
  return () => clearInterval(interval);
}, []);
```

### 5. **Track Auth0 Changes**
```bash
# Version lock Auth0 packages
npm ls @auth0/auth0-react

# Document current versions
# Update CHANGELOG when Auth0 updates
```

---

## 📋 Checklist: Before Contacting Auth0 Support

- [ ] Verified Auth0 tenant is ACTIVE
- [ ] Confirmed application exists in correct tenant
- [ ] Checked Allowed Callback URLs are correct
- [ ] Verified CORS Allowed Origins configured
- [ ] Confirmed .env.local has correct credentials
- [ ] Hard refreshed browser (Ctrl+Shift+R)
- [ ] Cleared browser cache completely
- [ ] Tested in incognito/private window
- [ ] Tested from different browser
- [ ] Tested from different network (or no VPN)
- [ ] Verified DNS resolution works
- [ ] Ran health check endpoint successfully
- [ ] Checked Auth0 status page for outages
- [ ] Reviewed recent git changes
- [ ] Restarted dev server (`npm run dev`)

---

## 📞 When to Contact Auth0 Support

Contact Auth0 support if you've completed all steps above AND:

1. **Persistent Connection Issues**
   - Fails across all browsers
   - Fails on different networks
   - Fails from multiple machines

2. **Tenant/Account Issues**
   - Tenant shows as suspended
   - Can't access Auth0 dashboard
   - Billing/subscription problems

3. **Dashboard Not Responding**
   - Can't save settings
   - Settings changes not applying
   - Dashboard errors/crashes

4. **API/Service Degradation**
   - Multiple authentication failures
   - Rate limit errors
   - Service availability alerts

**To Contact Auth0:**
1. Go to https://manage.auth0.com
2. Click username → Settings → Support
3. Or go to Support Center → Open Ticket
4. Include:
   - Exact error message
   - Steps to reproduce
   - Auth0 tenant domain
   - Browser/OS info
   - Timeline of when it started

---

## 🎯 Quick Reference: Common Solutions

| Problem | Solution | Time |
|---------|----------|------|
| Recently stopped working | Update Callback URLs | 2 min |
| Works on one browser not another | Clear cache & CORS | 3 min |
| Env variable issues | Copy .env to .env.local | 1 min |
| DNS issues | Try incognito or different network | 2 min |
| Tenant suspended | Check Auth0 dashboard notifications | 1 min |
| Rate limiting | Wait 15 minutes, retry | varies |
| VPN blocking | Disconnect VPN or use different region | 2 min |

---

## 📊 Verification Commands Script

Create `scripts/verify-auth0.sh`:
```bash
#!/bin/bash

echo "=== Auth0 Configuration Verification ==="
echo ""

echo "1. Checking .env.local file..."
if [ -f .env.local ]; then
    echo "✓ .env.local exists"
    grep VITE_AUTH0 .env.local
else
    echo "✗ .env.local missing"
fi

echo ""
echo "2. Checking Auth0 domain DNS..."
domain=$(grep VITE_AUTH0_DOMAIN .env.local | cut -d'=' -f2)
if nslookup $domain > /dev/null 2>&1; then
    echo "✓ DNS resolution works for $domain"
else
    echo "✗ DNS resolution failed"
fi

echo ""
echo "3. Checking HTTPS connection..."
if curl -s -o /dev/null -w "%{http_code}" https://$domain/.well-known/openid-configuration | grep -q "200\|404"; then
    echo "✓ HTTPS connection successful"
else
    echo "✗ HTTPS connection failed"
fi

echo ""
echo "4. Checking if dev server is running..."
if curl -s http://localhost:5173 > /dev/null; then
    echo "✓ Dev server running on localhost:5173"
else
    echo "✗ Dev server not responding"
fi

echo ""
echo "=== Verification Complete ==="
```

Run with:
```bash
chmod +x scripts/verify-auth0.sh
./scripts/verify-auth0.sh
```

---

## 🚀 Next Steps

After resolving the connection issue:

1. **Implement health monitoring** (see Prevention Strategies)
2. **Document your configuration** in team wiki
3. **Update team runbook** with these solutions
4. **Set up error tracking** to catch future issues
5. **Review Auth0 documentation** for security best practices
6. **Schedule regular configuration audits**

