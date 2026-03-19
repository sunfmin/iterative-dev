#!/bin/bash
# Verify iterative-dev skill produced expected artifacts
# Run this in the project directory AFTER the skill completes

SCOPE=$(cat .active-scope 2>/dev/null || echo "unknown")
TYPE=$(cat feature_list.json | grep -o '"type": *"[^"]*"' | head -1 | grep -o '"[^"]*"$' | tr -d '"')
TOTAL_FEATURES=$(cat feature_list.json | grep -c '"id":' || echo 0)
PASSING_FEATURES=$(cat feature_list.json | grep -c '"passes": true' || echo 0)
FEAT_COMMITS=$(git log --oneline | grep -c "feat:" || true)
REFINE_COMMITS=$(git log --oneline | grep -c "refine:" || true)
REFINEMENT_REPORTS=$(ls specs/$SCOPE/refinements/feature-*-refinement.md 2>/dev/null | wc -l | tr -d ' ')
SCREENSHOTS=$(ls specs/$SCOPE/screenshots/feature-*.png 2>/dev/null | wc -l | tr -d ' ')

PASS=0
FAIL=0

check() {
  if eval "$2"; then
    echo "  PASS: $1"
    ((PASS++))
  else
    echo "  FAIL: $1"
    ((FAIL++))
  fi
}

echo "=== Iterative-Dev Skill Verification ==="
echo "Scope: $SCOPE | Type: $TYPE | Features: $TOTAL_FEATURES"
echo ""

echo "--- Feature Completion ---"
check "All features pass ($PASSING_FEATURES/$TOTAL_FEATURES)" \
  "[ $PASSING_FEATURES -eq $TOTAL_FEATURES ]"

echo ""
echo "--- Implementation ---"
check "Feature commits exist ($FEAT_COMMITS)" \
  "[ $FEAT_COMMITS -ge $TOTAL_FEATURES ]"

echo ""
echo "--- Refinement (the critical gate) ---"
check "Refinement commits exist ($REFINE_COMMITS)" \
  "[ $REFINE_COMMITS -ge $TOTAL_FEATURES ]"
check "Refinement reports exist ($REFINEMENT_REPORTS)" \
  "[ $REFINEMENT_REPORTS -ge $TOTAL_FEATURES ]"
check "Refinements match features (commits: $REFINE_COMMITS >= features: $TOTAL_FEATURES)" \
  "[ $REFINE_COMMITS -ge $TOTAL_FEATURES ]"

if [ "$TYPE" = "web" ] || [ "$TYPE" = "mobile" ]; then
  echo ""
  echo "--- Screenshots (web/mobile) ---"
  # Count UI features (exclude infrastructure)
  UI_FEATURES=$(cat feature_list.json | grep -c '"full-stack"\|"functional"\|"style"' || true)
  check "Screenshots captured ($SCREENSHOTS for ~$UI_FEATURES UI features)" \
    "[ $SCREENSHOTS -gt 0 ]"
fi

echo ""
echo "--- Commit Pattern ---"
# Verify feat/refine alternation
PATTERN_OK=true
LAST=""
while IFS= read -r line; do
  TYPE_TAG=$(echo "$line" | grep -o "feat:\|refine:" || true)
  if [ "$TYPE_TAG" = "feat:" ] && [ "$LAST" = "feat:" ]; then
    PATTERN_OK=false  # Two feats in a row = missing refinement
  fi
  [ -n "$TYPE_TAG" ] && LAST=$TYPE_TAG
done < <(git log --oneline --reverse)
check "No consecutive feat: commits (refinement between each)" \
  "$PATTERN_OK"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ $FAIL -eq 0 ] && echo "ALL CHECKS PASSED" || echo "SOME CHECKS FAILED"
exit $FAIL
