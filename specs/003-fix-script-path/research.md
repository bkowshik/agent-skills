# Research: Fix Script Path Resolution

## Decision 1: Path Placeholder Convention

**Decision**: Use `{{SKILL_DIR}}` mustache-style template tokens in SKILL.md for all script path references.

**Rationale**:
- Mustache syntax (`{{ }}`) is widely recognized as a template placeholder convention
- Avoids collision with shell variable syntax (`$VAR`) that could be accidentally expanded
- Avoids collision with percent-delimited syntax (`%VAR%`) used in Windows batch files
- Each LLM tool's skill loader resolves `{{SKILL_DIR}}` to the skill's actual directory path at read time
- If a loader doesn't support resolution, the literal `{{SKILL_DIR}}` appears in the path, producing a clear error rather than a silently wrong path

**Alternatives considered**:
- `$SKILL_DIR` (shell-style): Rejected — risk of premature shell expansion
- `%SKILL_DIR%` (percent-delimited): Rejected — less widely recognized outside Windows
- Hardcoded `.agents/skills/squash-commits/`: Rejected — couples SKILL.md to a specific directory structure, breaks portability across LLM tools

## Decision 2: Scope of Changes

**Decision**: Only modify path references in SKILL.md. Do not modify the helper script (`squash.sh`) or any other files.

**Rationale**: The bug is purely in how SKILL.md communicates the script's location to the AI agent. The script itself works correctly when given the right path.

**Alternatives considered**:
- Making the script self-locating (e.g., using `$0`): Rejected — the script already works; the issue is the AI agent not knowing where to find it
- Adding a path resolution wrapper script: Rejected — unnecessary complexity for a documentation fix

## Decision 3: Replacement Scope

**Decision**: Replace all 9 occurrences of `scripts/squash.sh` in SKILL.md with `{{SKILL_DIR}}/scripts/squash.sh`.

**Rationale**: Consistent use of the placeholder across all references (code blocks, inline text, examples) ensures no path can be missed regardless of which section the AI agent reads first.

**Occurrences to update** (line numbers from current SKILL.md):
1. Line 19: Inline reference in "How it works" section
2. Line 31: Code block — dry-run command
3. Line 91: Code block — execute command
4. Line 118: Code block — dry-run with base-branch
5. Line 124: Code block — execute with base-branch
6. Line 135: Code block — example with develop
7. Line 173: Inline reference in example walkthrough
8. Line 198: Inline reference in example walkthrough
