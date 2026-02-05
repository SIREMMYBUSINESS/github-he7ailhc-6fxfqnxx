#!/bin/bash

# Auth0 Configuration Verification Script
# Usage: ./scripts/verify-auth0.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Auth0 Configuration Verification ===${NC}\n"

# Helper functions
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# 1. Check .env.local exists
echo -e "${BLUE}1. Environment Configuration${NC}"
if [ -f .env.local ]; then
    check_pass ".env.local exists"
else
    check_fail ".env.local missing (required for local development)"
    echo "   Run: cp .env .env.local"
fi

# 2. Check Auth0 variables
echo ""
echo -e "${BLUE}2. Auth0 Credentials${NC}"

domain=$(grep -i "VITE_AUTH0_DOMAIN" .env .env.local 2>/dev/null | tail -1 | cut -d'=' -f2 | tr -d ' ')
client_id=$(grep -i "VITE_AUTH0_CLIENT_ID" .env .env.local 2>/dev/null | tail -1 | cut -d'=' -f2 | tr -d ' ')
audience=$(grep -i "VITE_AUTH0_AUDIENCE" .env .env.local 2>/dev/null | tail -1 | cut -d'=' -f2 | tr -d ' ')

if [ -z "$domain" ]; then
    check_fail "VITE_AUTH0_DOMAIN not found"
else
    check_pass "VITE_AUTH0_DOMAIN = $domain"
fi

if [ -z "$client_id" ]; then
    check_fail "VITE_AUTH0_CLIENT_ID not found"
else
    check_pass "VITE_AUTH0_CLIENT_ID = ${client_id:0:10}..."
fi

if [ -z "$audience" ]; then
    check_fail "VITE_AUTH0_AUDIENCE not found"
else
    check_pass "VITE_AUTH0_AUDIENCE = $audience"
fi

# 3. Check domain format
echo ""
echo -e "${BLUE}3. Domain Format Validation${NC}"

if [[ $domain =~ \.auth0\.com$ ]]; then
    check_pass "Auth0 domain format is valid"
else
    check_fail "Auth0 domain format invalid: $domain"
fi

# 4. Check DNS resolution
echo ""
echo -e "${BLUE}4. Network Connectivity${NC}"

if command -v nslookup &> /dev/null; then
    if nslookup "$domain" > /dev/null 2>&1; then
        check_pass "DNS resolution works for $domain"
    else
        check_fail "DNS resolution failed for $domain"
        check_warn "Try: nslookup $domain"
    fi
else
    check_warn "nslookup not available, skipping DNS check"
fi

# 5. Check HTTPS connectivity (using curl)
echo ""
echo -e "${BLUE}5. HTTPS Connection${NC}"

if command -v curl &> /dev/null; then
    http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 \
        "https://${domain}/.well-known/openid-configuration" 2>/dev/null || echo "000")

    if [[ $http_code == "200" ]]; then
        check_pass "HTTPS connection successful (HTTP $http_code)"
    elif [[ $http_code == "000" ]]; then
        check_fail "Connection refused or timeout"
    else
        check_pass "HTTPS response received (HTTP $http_code)"
    fi
else
    check_warn "curl not available, skipping HTTPS check"
fi

# 6. Check if dev server is running
echo ""
echo -e "${BLUE}6. Development Environment${NC}"

if command -v curl &> /dev/null; then
    if curl -s http://localhost:5173 > /dev/null 2>&1; then
        check_pass "Dev server running on http://localhost:5173"
    else
        check_warn "Dev server not responding on http://localhost:5173"
        check_warn "Run: npm run dev"
    fi
else
    check_warn "curl not available, skipping dev server check"
fi

# 7. Check package.json for Auth0 dependencies
echo ""
echo -e "${BLUE}7. Package Dependencies${NC}"

if grep -q "@auth0/auth0-react" package.json; then
    check_pass "@auth0/auth0-react is installed"
else
    check_fail "@auth0/auth0-react not found in package.json"
fi

# 8. Check node_modules
echo ""
echo -e "${BLUE}8. Node Modules${NC}"

if [ -d "node_modules/@auth0" ]; then
    check_pass "Auth0 packages are installed"
else
    check_warn "Auth0 packages not in node_modules"
    check_warn "Run: npm install"
fi

# 9. Summary
echo ""
echo -e "${BLUE}=== Verification Summary ===${NC}"

if [ -n "$domain" ] && [ -n "$client_id" ] && [[ $domain =~ \.auth0\.com$ ]]; then
    check_pass "Configuration looks valid"
    echo ""
    echo "Next steps:"
    echo "1. Verify Callback URLs in Auth0 Dashboard:"
    echo "   http://localhost:5173/callback"
    echo "   https://your-domain.com/callback"
    echo ""
    echo "2. Verify CORS Origins in Auth0 Dashboard:"
    echo "   http://localhost:5173"
    echo "   https://your-domain.com"
    echo ""
    echo "3. Start dev server:"
    echo "   npm run dev"
else
    check_fail "Configuration is incomplete"
fi

echo ""
