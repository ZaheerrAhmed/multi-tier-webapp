#!/bin/bash
# Health check script — verifies all 5 services are reachable
# Run from host: bash scripts/health-check.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }
info() { echo -e "${YELLOW}[INFO]${NC} $1"; }

echo "================================================"
echo "  OpsBoard — Service Health Check"
echo "================================================"

check_port() {
  local host=$1
  local port=$2
  local service=$3
  if vagrant ssh "$4" -c "exec 3<>/dev/tcp/$host/$port 2>/dev/null && echo ok" 2>/dev/null | grep -q ok; then
    pass "$service ($host:$port)"
  else
    fail "$service ($host:$port) — not reachable"
  fi
}

info "Checking VM status..."
vagrant status 2>/dev/null | grep -E "running|poweroff|not created"

echo ""
info "Checking service ports..."

# Check MySQL from app01
check_port db01 3306 "MySQL (MariaDB)" app01

# Check Memcached from app01
check_port mc01 11211 "Memcached" app01

# Check RabbitMQ from app01
check_port rmq01 5672 "RabbitMQ" app01

# Check Tomcat from web01
check_port app01 8080 "Tomcat" web01

# Check Nginx from host
if curl -s -o /dev/null -w "%{http_code}" http://192.168.56.11 | grep -q "200\|301\|302"; then
  pass "Nginx (192.168.56.11:80)"
else
  fail "Nginx (192.168.56.11:80) — not reachable"
fi

echo ""
info "Checking app login page..."
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://192.168.56.11/)
if [ "$STATUS" = "200" ]; then
  pass "Application is UP — http://192.168.56.11 (HTTP $STATUS)"
else
  fail "Application returned HTTP $STATUS"
fi

echo "================================================"
