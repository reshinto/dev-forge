---
name: security-coverage-audit
description: Run security checks (OWASP client-side) and verify test coverage thresholds with E2E validation
user-invocable: true
---

# Security & Coverage Audit

## Task

Run a combined security and test coverage audit to verify the project meets quality and safety thresholds.

## Steps

### 1. Coverage Verification

- Run `npm run test -- --coverage`
- Verify coverage meets project-defined thresholds (see `rules/testing.md`)
- Identify any files below thresholds

### 2. E2E Test Validation

- Run `npm run e2e` (dev server starts automatically via hooks)
- See `rules/testing.md` for E2E spec conventions
- Confirm 3-viewport coverage: desktop (1280px), tablet (768px), mobile (375px)

### 3. OWASP Client-Side Security

- Run `npm audit` and report vulnerabilities
- Scan for `eval()`, `Function()`, `innerHTML` usage: `grep -r "eval\|innerHTML\|Function(" src/`
- Verify no `dangerouslySetInnerHTML` in components
- Check that any code editor or REPL components are read-only by default with no script execution
- Verify user inputs are sanitized before passing to any processing function
- Confirm no inline event handlers with string code

### 4. CSP Compliance

- No inline `<script>` tags in `index.html`
- No `unsafe-eval` or `unsafe-inline` in Content Security Policy
- External resources loaded with integrity hashes where possible

### 5. Dependency Security

- Check `package-lock.json` for known vulnerabilities
- Flag any dependency with critical or high severity
- Verify no unnecessary runtime dependencies (dev deps not in production bundle)

### 6. Test Quality Analysis

- **Edge case gaps**: Identify missing edge case tests (empty inputs, boundary values, error conditions)
- **Test quality scoring**: Evaluate tests beyond coverage % — are assertions meaningful? Do tests verify behavior or just structure?
- **Critical path coverage**: Ensure the most important execution paths have thorough test coverage
- **Mutation resistance**: Would the tests catch a subtle bug (e.g., off-by-one, wrong comparison operator)?

## Rules

- Do not suppress security findings without documenting the exception
- Coverage below project-defined thresholds is a blocker — do not approve without justification
- Security findings at high/critical severity are blockers

## Output Format

- PASS: [area] - details
- FAIL: [area] - details + remediation steps
- BLOCKED: [finding] - must resolve before merge
