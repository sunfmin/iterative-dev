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

# 2. Ensure screenshot and refinement directories exist
# Screenshots are committed to the repo as results — never delete them
SCOPE=$(cat .active-scope 2>/dev/null || echo "default")
SCREENSHOT_DIR="specs/$SCOPE/screenshots"
mkdir -p "$SCREENSHOT_DIR"
mkdir -p "specs/$SCOPE/refinements"
rm -rf test-results 2>/dev/null || true

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

# 9. Verify cross-component connectivity (for full-stack projects)
# Adapt the URL and port to match your project's API prefix and backend port
echo "Verifying backend API..."
API_URL="http://localhost:8082"  # adjust to your backend URL and API prefix
API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/" 2>/dev/null || echo "000")
if [ "$API_RESPONSE" = "404" ]; then
  echo "⚠️  WARNING: Backend returns 404 — route prefix may be misconfigured"
fi
CORS_HEADER=$(curl -s -I -X OPTIONS "$API_URL/" -H 'Origin: http://localhost:3000' 2>/dev/null | grep -i 'access-control-allow-origin' || echo "")
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

# 2. Ensure screenshot and refinement directories exist
# Screenshots are committed to the repo as results — never delete them
SCOPE=$(cat .active-scope 2>/dev/null || echo "default")
mkdir -p "specs/$SCOPE/screenshots" "specs/$SCOPE/refinements"
rm -rf test-results/ 2>/dev/null || true

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

## Cross-Component Connectivity Verification (IMPORTANT)

For projects where components run on different ports or domains (e.g., frontend + backend, microservices, API gateway + services), **always verify cross-component connectivity** after starting services. The most common failures are:
- **Requests blocked by CORS** — browsers enforce cross-origin restrictions that tools like `curl` bypass
- **Routes not matching between client and server** — route prefixes, path mismatches, or code generators omitting URL prefixes
- **Auth tokens not forwarded** — credentials or headers dropped between components

Verify connectivity by testing the actual paths your components use to communicate. For example, in a web project with a frontend on port 3000 and backend on port 8080:

```bash
# Example: Verify backend API responds at the path the frontend expects
curl -s http://localhost:8080/api/v1/health || curl -s http://localhost:8080/api/v1/<any-list-endpoint> | head -3
# If 404: the route prefix may be misconfigured between client and server.

# Example: Verify CORS headers are present (web projects only)
curl -s -I -X OPTIONS http://localhost:8080/api/v1/<any-endpoint> \
  -H 'Origin: http://localhost:3000' | grep -i 'access-control'
# If no Access-Control-Allow-Origin header: add CORS middleware to the backend.
```

Adapt these checks to your project's architecture — the principle is the same regardless of language or framework: verify that each component can reach the others at the expected paths with the expected headers.
