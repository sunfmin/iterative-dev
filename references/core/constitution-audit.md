# Constitution Audit Workflow

When a scope involves aligning a codebase with a reference document (constitution, style guide, AGENTS.md, coding standards, etc.), the init-scope workflow MUST use this systematic audit process instead of ad-hoc exploration.

## When to Use

Use this workflow when the user's scope description includes phrases like:
- "align with", "comply with", "follow", "match"
- "refactor to match AGENTS.md / constitution / standards"
- "audit against", "check compliance with"
- Any scope that references an external document as the source of truth

## The Problem This Solves

Ad-hoc auditing (reading the doc once and listing gaps from memory) misses requirements because:
1. Constitution documents are long (often 1000+ lines) with many specific rules
2. Rules are scattered across sections — a "Service Architecture" section may have rules about testing
3. Code examples contain implicit requirements (e.g., a code example showing `api.CreateProductReq` implies services must use generated types)
4. Some rules are stated as "MUST" / "CRITICAL" / "NON-NEGOTIABLE" but are easy to overlook in a single pass
5. A single agent can't hold the entire document + entire codebase in context simultaneously

## Systematic Audit Process

### Step 1: Extract Requirements (per-section subagents)

Split the constitution document into logical sections. For EACH section, launch a **dedicated subagent** that:

1. Reads ONLY that section of the constitution thoroughly
2. Extracts every concrete, testable requirement as a checklist item
3. For each requirement, identifies:
   - The exact rule (quote the relevant text)
   - What file(s) / pattern(s) to check in the codebase
   - How to verify compliance (what to grep for, what to read, what to run)

**Subagent prompt template for extraction:**

```
You are extracting requirements from a section of a project constitution document.

## Section to Analyze
{paste the section text here — NOT a file path, paste the actual content}

## Instructions
1. Read this section carefully — every sentence may contain a requirement
2. Extract EVERY concrete, testable requirement. Include:
   - Requirements stated with MUST, CRITICAL, NON-NEGOTIABLE
   - Requirements implied by code examples (e.g., if an example shows `cmp.Diff`, that means "tests MUST use cmp.Diff")
   - Requirements about file locations, naming conventions, patterns
   - Requirements about what NOT to do (anti-patterns)
3. For each requirement, output:
   - rule: The exact requirement (quote or paraphrase)
   - check: How to verify it in the codebase (file to read, grep pattern, command to run)
   - section: Which constitution section it comes from

Output as a numbered list. Be exhaustive — it's better to extract too many requirements than to miss one.
```

### Step 2: Verify Each Requirement Against Codebase

For each extracted requirement, launch verification subagents (can batch related requirements together). Each subagent:

1. Reads the specific files mentioned in the "check" field
2. Determines: COMPLIANT or VIOLATION
3. For violations: describes exactly what's wrong and what the fix would be

**Subagent prompt template for verification:**

```
You are auditing a codebase against specific requirements from a project constitution.

## Requirements to Verify
{numbered list of requirements with their check instructions}

## Instructions
For each requirement:
1. Run the check (read file, grep, etc.)
2. Determine: COMPLIANT or VIOLATION
3. If VIOLATION: describe what's wrong and what the fix should be

Output format:
- Requirement #N: COMPLIANT | VIOLATION
  - Current: {what the code does now}
  - Required: {what the constitution requires}
  - Fix: {description of needed change}
```

### Step 3: Generate Feature List from Violations

Group related violations into features. Each feature should:
- Fix ONE specific pattern or concern (not mix unrelated changes)
- Have concrete, verifiable test steps
- Include the exact constitution rule being addressed
- Be ordered: dependencies first (e.g., fix types before fixing code that uses those types)

### Key Principles

1. **Read the actual text, not summaries** — Subagents must receive the actual constitution text, not a summary. Summaries lose details.

2. **One section per extraction pass** — Don't try to extract requirements from the entire document at once. Split into sections of ~200 lines max per subagent.

3. **Code examples are requirements** — If the constitution shows a code example, every aspect of that example is a requirement. If it shows `NewService(db).WithLogger(log).Build()`, then:
   - Services MUST have builder pattern
   - Builder MUST accept db as constructor arg
   - Builder MUST have WithLogger method
   - Builder MUST have Build method
   - Build MUST return an interface

4. **Cross-reference sections** — Requirements in one section may affect code covered by another section. The verification step catches this because it checks actual code.

5. **Don't skip "obvious" checks** — Even if something seems likely to be compliant, verify it. The whole point is that "obvious" assumptions cause missed requirements.

## Example: Auditing Against AGENTS.md

For a document like AGENTS.md with sections on Testing, Architecture, Error Handling, etc.:

**Extraction subagents:**
- Agent 1: Extract requirements from "Testing Principles" section
- Agent 2: Extract requirements from "Service Architecture" section
- Agent 3: Extract requirements from "Error Handling" section
- Agent 4: Extract requirements from "OpenAPI/ogen Workflow" section
- Agent 5: Extract requirements from "Frontend Constitution" section
- Agent 6: Extract requirements from "Development Workflow" section

**Verification subagents** (can run in parallel):
- Agent A: Verify testing requirements against backend/tests/
- Agent B: Verify architecture requirements against backend/services/, handlers/
- Agent C: Verify error handling against backend/handlers/error_*.go
- Agent D: Verify OpenAPI requirements against api/openapi/ and generated code
- Agent E: Verify frontend requirements against frontend/src/ and frontend/tests/

**Result:** A comprehensive feature list with zero missed requirements.
