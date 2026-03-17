# Data Pipeline Verification Strategy

Verify data pipeline features through input/output validation, transformation tests, and data quality checks.

**This is the verification strategy for project type: `data`**

## Overview

Data pipeline projects are verified through:
1. **Transformation tests** — Input data → expected output data
2. **Schema validation** — Output matches expected schema/types
3. **Data quality checks** — No nulls where unexpected, no duplicates, correct aggregations
4. **Edge case coverage** — Empty datasets, malformed records, schema evolution

## Process

### Step 1: Ensure Environment is Ready

```bash
# Check database/data services are running (adjust for your project)
docker-compose ps                           # Docker services
psql -c "SELECT 1" 2>/dev/null             # PostgreSQL
python -c "import pandas; print('OK')"     # Python deps
```

If not running, start with `bash init.sh`.

### Step 2: Write Pipeline Tests

Every feature MUST have tests covering:

**Happy path:**
```
- Valid input data → correct transformed output
- Aggregations produce correct totals/counts
- Joins produce correct merged records
- Output schema matches specification
```

**Error cases:**
```
- Malformed input records → skipped or logged (not crash)
- Missing required fields → clear error or default value
- Type mismatches → coercion or descriptive error
- Connection failures → retry or clear error
```

**Edge cases:**
```
- Empty dataset → empty output (not crash or null)
- Single record → works correctly
- Very large dataset → completes within resource limits
- Duplicate records → handled per spec (dedupe, keep-all, etc.)
- Null/missing values → handled consistently
- Schema evolution → backward-compatible
```

### Example Test Patterns

#### Python (pytest + pandas)
```python
def test_transform_sales_data():
    input_df = pd.DataFrame({
        'date': ['2024-01-01', '2024-01-01', '2024-01-02'],
        'product': ['A', 'B', 'A'],
        'amount': [100, 200, 150]
    })
    result = transform_sales(input_df)

    assert len(result) == 2  # Grouped by date
    assert result.loc[result['date'] == '2024-01-01', 'total'].values[0] == 300
    assert result.loc[result['date'] == '2024-01-02', 'total'].values[0] == 150

def test_transform_handles_empty():
    empty_df = pd.DataFrame(columns=['date', 'product', 'amount'])
    result = transform_sales(empty_df)
    assert len(result) == 0
    assert list(result.columns) == ['date', 'total']  # Schema preserved

def test_transform_handles_nulls():
    input_df = pd.DataFrame({
        'date': ['2024-01-01', None],
        'product': ['A', 'B'],
        'amount': [100, None]
    })
    result = transform_sales(input_df)
    assert result['total'].isna().sum() == 0  # No nulls in output
```

#### SQL (dbt tests)
```yaml
# schema.yml
models:
  - name: sales_summary
    columns:
      - name: date
        tests: [not_null, unique]
      - name: total
        tests: [not_null]
    tests:
      - dbt_utils.expression_is_true:
          expression: "total >= 0"
```

#### Spark (PySpark)
```python
def test_aggregate_orders(spark):
    input_data = [("2024-01-01", "A", 100), ("2024-01-01", "B", 200)]
    input_df = spark.createDataFrame(input_data, ["date", "product", "amount"])

    result = aggregate_orders(input_df)

    assert result.count() == 1
    row = result.collect()[0]
    assert row["total"] == 300
```

### Step 3: Run Tests

```bash
pytest tests/ -v                          # Python
dbt test                                   # dbt
spark-submit --master local tests/         # Spark
go test ./pipeline/...                     # Go
```

### Step 4: Verify Data Quality

After tests pass, verify:

1. **Schema correct** — Output columns/fields match spec
2. **No data loss** — Row counts match expectations (input vs output)
3. **No duplicates** — Unless explicitly expected
4. **Aggregations correct** — Spot-check totals manually
5. **Null handling consistent** — Documented and tested
6. **Idempotent** — Running pipeline twice produces same result

### Step 5: Validate with Sample Data

Run the pipeline against a representative sample:

```bash
# Run with test fixtures
python -m pipeline --input fixtures/sample_input.csv --output /tmp/output.csv

# Verify output
python -c "
import pandas as pd
df = pd.read_csv('/tmp/output.csv')
print(f'Rows: {len(df)}')
print(f'Columns: {list(df.columns)}')
print(f'Nulls: {df.isnull().sum().to_dict()}')
print(df.head())
"
```

## Verification Checklist

For each data feature, verify:

- [ ] Input → output transformation is correct
- [ ] Output schema matches specification
- [ ] Null/missing values handled consistently
- [ ] Empty input produces empty output (not error)
- [ ] Aggregations are mathematically correct
- [ ] No unintended data loss or duplication
- [ ] Pipeline is idempotent (safe to re-run)
- [ ] Error records are logged/quarantined (not silently dropped)
- [ ] Performance is acceptable for expected data volumes

## Parent Agent Post-Verification

After subagent completes, parent MUST:
1. Confirm all tests pass
2. Verify output schema matches spec
3. Check that edge cases (empty, null, duplicate) are tested
4. If data quality checks seem thin, launch a follow-up subagent
