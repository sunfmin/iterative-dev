# API Verification Strategy

Verify API features through integration tests, endpoint validation, and contract testing.

**This is the verification strategy for project type: `api`**

## Overview

API projects are verified through:
1. **Integration tests** — Hit real endpoints with real requests
2. **Response validation** — Check status codes, response shapes, error formats
3. **Contract compliance** — Responses match OpenAPI/schema definitions
4. **Edge case coverage** — Invalid input, auth failures, not-found, rate limits

## Process

### Step 1: Ensure Environment is Running

```bash
# Check API server is running (adjust port for your project)
lsof -i :8080 | head -2
curl -s http://localhost:8080/health || echo "API not responding"
```

If not running, start with `bash init.sh`.

### Step 2: Write Integration Tests

Every feature MUST have integration tests covering:

**Happy path:**
```
- Valid request → correct status code + response body
- All required fields present in response
- Correct content-type header
```

**Error cases:**
```
- Missing required fields → 400 with descriptive error
- Invalid field values → 400 with field-specific errors
- Unauthorized → 401 with error message
- Forbidden → 403 with error message
- Not found → 404 with error message
- Conflict/duplicate → 409 with error message
```

**Edge cases:**
```
- Empty collections → 200 with empty array (not null)
- Pagination boundaries → correct page/total counts
- Large payloads → handled gracefully
- Concurrent requests → no race conditions
```

### Example Test Patterns

#### Go (net/http/httptest)
```go
func TestCreateProduct(t *testing.T) {
    srv := setupTestServer(t)

    resp, err := srv.Client().Post(srv.URL+"/api/products",
        "application/json",
        strings.NewReader(`{"name": "Test", "price": 9.99}`))
    require.NoError(t, err)
    require.Equal(t, http.StatusCreated, resp.StatusCode)

    var product Product
    json.NewDecoder(resp.Body).Decode(&product)
    assert.Equal(t, "Test", product.Name)
    assert.NotEmpty(t, product.ID)
}
```

#### Python (pytest + requests)
```python
def test_create_product(api_client):
    resp = api_client.post("/api/products", json={"name": "Test", "price": 9.99})
    assert resp.status_code == 201
    data = resp.json()
    assert data["name"] == "Test"
    assert "id" in data
```

#### Node.js (vitest + supertest)
```typescript
test('POST /api/products creates a product', async () => {
  const res = await request(app)
    .post('/api/products')
    .send({ name: 'Test', price: 9.99 })
    .expect(201);

  expect(res.body.name).toBe('Test');
  expect(res.body.id).toBeDefined();
});
```

### Step 3: Run Tests

```bash
# Use the project's test command
go test ./...                    # Go
pytest tests/                    # Python
npm test                         # Node.js
```

### Step 4: Verify Test Quality

After tests pass, verify they are thorough:

1. **Coverage check** — Are all endpoints tested?
2. **Error paths tested** — Not just happy paths?
3. **Response shape validated** — Not just status codes?
4. **Auth tested** — Protected endpoints reject unauthorized requests?
5. **Idempotency** — Can tests run multiple times without side effects?

### Step 5: Document Results

Record in the subagent's output:
- Endpoints tested (method + path)
- Status codes verified
- Error scenarios covered
- Any issues found and fixed

## Verification Checklist

For each API feature, verify:

- [ ] All endpoints return correct status codes
- [ ] Response bodies match expected schema
- [ ] Error responses have consistent format (e.g., `{"error": "message", "details": [...]}`)
- [ ] Authentication/authorization enforced on protected endpoints
- [ ] Input validation rejects malformed data with helpful errors
- [ ] Pagination works correctly (page, limit, total, next/prev)
- [ ] Filters and search return correct subsets
- [ ] CRUD operations are complete (create, read, update, delete all work)
- [ ] Concurrent access doesn't cause data corruption

## Parent Agent Post-Verification

After subagent completes, parent MUST:
1. Confirm all tests pass: check test output or run a quick smoke test
2. Verify error handling is tested (not just happy paths)
3. If coverage seems thin, launch a follow-up subagent to add missing test cases
