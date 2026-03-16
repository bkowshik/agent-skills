# Data Model: Remove LLM Attribution from Squashed Commit Messages

## Entities

### Trailer

A git trailer line extracted from commit messages.

- **Key**: Full trailer string (e.g., `Co-authored-by: Jane Doe <jane@example.com>`)
- **Type**: Either `Co-authored-by` or `Signed-off-by`
- **Classification**: Human or LLM/bot (determined by email pattern matching)

### LLM Email Pattern

A known email pattern identifying an AI tool or bot as the trailer author.

- **Pattern**: Email domain or substring (e.g., `noreply@anthropic.com`)
- **Tool**: The associated AI tool or bot service
- **Match type**: Case-insensitive substring match against the trailer's email address

## State Transitions

```
Original Commits
    │
    ▼
[Extract trailers] ── squash.sh line 180-181 (existing)
    │
    ▼
[Deduplicate] ── sort -u (existing)
    │
    ▼
[Filter LLM trailers] ── grep -v -i -E '<patterns>' (NEW)
    │
    ▼
Human-only Trailers → output in TRAILERS section
    │
    ▼
[Agent synthesizes message] ── SKILL.md Step 2
    │  (explicit: do NOT add own attribution)
    ▼
Final Commit Message = Summary + Human Trailers only
```
