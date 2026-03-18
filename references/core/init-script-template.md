# init.sh Template

The `init.sh` script sets up the development environment. It must be idempotent (safe to run multiple times).

## Requirements

1. **Kill existing processes** — Clean slate
2. **Clean old test artifacts** — Fresh test results
3. **Install/build dependencies** — Ensure latest code
4. **Start required services** — Servers, databases, etc.
5. **Be idempotent** — Safe to run multiple times

## Templates by Project Type

### Web Project (Frontend + Backend)

```bash
#!/bin/bash
set -e

echo "=== Web Development Environment ==="

# 1. Kill existing servers
echo "Stopping existing servers..."
pkill -f 'go run' 2>/dev/null || true
pkill -f 'vite' 2>/dev/null || true
pkill -f 'node.*dev' 2>/dev/null || true
sleep 1

# 2. Delete old screenshots for fresh test results
# Note: screenshot dir is e2e/screenshots/ relative to playwright.config.ts
# For monorepo (frontend/ subdir): clean frontend/e2e/screenshots/
# For standalone frontend (root): clean e2e/screenshots/
echo "Cleaning old test artifacts..."
SCREENSHOT_DIR="e2e/screenshots"  # adjust to "frontend/e2e/screenshots" for monorepos
rm -rf "$SCREENSHOT_DIR"/*.png 2>/dev/null || true
rm -rf test-results 2>/dev/null || true
mkdir -p "$SCREENSHOT_DIR"

# 3. Install/update dependencies
echo "Installing dependencies..."
cd frontend && npm install && cd ..
cd backend && go mod download && cd ..

# 4. Build backend
echo "Building backend..."
cd backend && go build -o backend . && cd ..

# 5. Start database
echo "Ensuring database is running..."
brew services start postgresql@18 2>/dev/null || true

# 6. Start backend
echo "Starting backend on port 8082..."
cd backend && ./backend &
cd ..

# 7. Start frontend
echo "Starting frontend on port 3000..."
cd frontend && npm run dev &
cd ..

# 8. Wait and verify
sleep 3

# 9. Verify backend API and CORS (for full-stack projects)
echo "Verifying backend API..."
API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8082/api/v1/ 2>/dev/null || echo "000")
if [ "$API_RESPONSE" = "404" ]; then
  echo "⚠️  WARNING: Backend returns 404 for /api/v1/ — route prefix may be misconfigured"
fi
CORS_HEADER=$(curl -s -I -X OPTIONS http://localhost:8082/api/v1/ -H 'Origin: http://localhost:3000' 2>/dev/null | grep -i 'access-control-allow-origin' || echo "")
if [ -z "$CORS_HEADER" ]; then
  echo "⚠️  WARNING: No CORS headers detected — frontend requests will be blocked by browser"
fi

echo ""
echo "Active scope: $(cat .active-scope 2>/dev/null || echo 'none')"
```

### API Project

```bash
#!/bin/bash
set -e

echo "=== API Development Environment ==="

# 1. Kill existing servers
pkill -f 'go run' 2>/dev/null || true
pkill -f 'node.*server' 2>/dev/null || true
pkill -f 'uvicorn\|gunicorn' 2>/dev/null || true
sleep 1

# 2. Clean test artifacts
rm -rf test-results 2>/dev/null || true

# 3. Install dependencies
go mod download          # Go
# npm install            # Node.js
# pip install -r requirements.txt  # Python

# 4. Start database
docker-compose up -d db 2>/dev/null || true
sleep 2

# 5. Run migrations
go run ./cmd/migrate up  # or equivalent

# 6. Start API server
go run ./cmd/server &
# npm start &            # Node.js
# uvicorn app:app &      # Python

sleep 2
echo ""
echo "Active scope: $(cat .active-scope 2>/dev/null || echo 'none')"
```

### CLI Project

```bash
#!/bin/bash
set -e

echo "=== CLI Development Environment ==="

# 1. Clean old artifacts
rm -rf bin/ 2>/dev/null || true
rm -rf test-results 2>/dev/null || true

# 2. Install dependencies
go mod download          # Go
# cargo build            # Rust
# npm install            # Node.js
# pip install -e .       # Python

# 3. Build the CLI tool
mkdir -p bin
go build -o bin/mytool ./cmd/mytool  # Go
# cargo build && cp target/debug/mytool bin/  # Rust
# npm run build          # Node.js

# 4. Verify build
./bin/mytool --version || echo "Build may have failed"

echo ""
echo "Active scope: $(cat .active-scope 2>/dev/null || echo 'none')"
```

### Library Project

```bash
#!/bin/bash
set -e

echo "=== Library Development Environment ==="

# 1. Clean old artifacts
rm -rf dist/ build/ 2>/dev/null || true
rm -rf test-results coverage/ 2>/dev/null || true

# 2. Install dependencies
go mod download          # Go
# cargo build            # Rust
# npm install            # Node.js
# pip install -e ".[dev]"  # Python

# 3. Verify build
go build ./...           # Go
# cargo check            # Rust
# npm run build          # Node.js
# python -m py_compile src/*.py  # Python

echo ""
echo "Active scope: $(cat .active-scope 2>/dev/null || echo 'none')"
```

### Data Pipeline Project

```bash
#!/bin/bash
set -e

echo "=== Data Pipeline Development Environment ==="

# 1. Kill existing processes
pkill -f 'spark\|airflow' 2>/dev/null || true

# 2. Clean old artifacts
rm -rf output/ test-results/ 2>/dev/null || true

# 3. Install dependencies
pip install -r requirements.txt
# pip install -e ".[dev]"

# 4. Start data services
docker-compose up -d     # Database, message queue, etc.
sleep 3

# 5. Prepare test data
python scripts/seed_test_data.py 2>/dev/null || true

echo ""
echo "Active scope: $(cat .active-scope 2>/dev/null || echo 'none')"
```

### Mobile Project

```bash
#!/bin/bash
set -e

echo "=== Mobile Development Environment ==="

# 1. Kill existing processes
pkill -f 'metro\|react-native' 2>/dev/null || true

# 2. Clean old artifacts
rm -rf test-results/ screenshots/ 2>/dev/null || true
mkdir -p screenshots

# 3. Install dependencies
npm install
# cd ios && pod install && cd ..  # iOS

# 4. Start backend (if needed)
cd backend && npm start &
cd ..

# 5. Start Metro bundler (React Native)
npx react-native start &
# flutter pub get         # Flutter

sleep 3
echo ""
echo "Active scope: $(cat .active-scope 2>/dev/null || echo 'none')"
```

## Customization

Adapt whichever template best matches your project. The key is:
1. Idempotent — safe to run repeatedly
2. Clean artifacts — fresh test results each time
3. All services started — everything needed to develop and test
4. Active scope displayed — quick confirmation of current work

## Verification Commands

After running init.sh, verify services:

```bash
# Check what's running
lsof -i :3000  # Frontend
lsof -i :8080  # API server
lsof -i :5432  # PostgreSQL

# Test endpoints
curl -s http://localhost:8080/health || echo "Server not responding"

# Verify tool builds
./bin/mytool --version 2>/dev/null || echo "CLI not built"
```

## Web Project: CORS and Route Prefix Verification (IMPORTANT)

For full-stack web projects where the frontend and backend run on different ports, **always verify CORS and route prefixes** after starting services. These are the #1 and #2 most common causes of "frontend can't load data" bugs.

```bash
# 1. Verify backend API responds (not 404)
# If using an API prefix like /api/v1, test the full path:
curl -s http://localhost:8080/api/v1/health || curl -s http://localhost:8080/api/v1/<any-list-endpoint> | head -3
# If 404: the backend route registration doesn't include the prefix.
# Common with code generators (ogen, openapi-generator) that register routes
# without the OpenAPI servers.url prefix. Fix by mounting under the prefix.

# 2. Verify CORS headers are set
curl -s -I -X OPTIONS http://localhost:8080/api/v1/<any-endpoint> \
  -H 'Origin: http://localhost:3000' | grep -i 'access-control'
# If no Access-Control-Allow-Origin header: add CORS middleware to the backend.
# Without CORS headers, browsers block all requests from the frontend.
```
