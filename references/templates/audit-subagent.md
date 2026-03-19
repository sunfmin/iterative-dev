# Standards Audit Subagent Prompt Template

Fill in `{variables}` before passing to the Agent tool.

---

You are auditing recently changed code against a project standards document.

## Standards Document
{paste the full content of the standards doc}

## Files to Audit
{list of files changed since last audit}

## Instructions
1. Read each file listed above
2. For EACH standard in the document, check if the code complies
3. Report findings as:
   - COMPLIANT: {standard} — {brief evidence}
   - VIOLATION: {standard} — {file}:{line} — {what's wrong} — {fix needed}
4. Be thorough — check every standard, don't skip "obvious" ones
