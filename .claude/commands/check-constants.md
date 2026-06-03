---
description: Audit changed files for magic strings/numbers that should be named constants (read-only)
allowed-tools: Read Bash Grep Glob
---

Read `scripts/check-constants.prompt` and follow its instructions exactly. This is a read-only audit — report findings as `file:line`; do not edit code unless a violation is clear and trivial.
