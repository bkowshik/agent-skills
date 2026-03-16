# Research: Remove LLM Attribution from Squashed Commit Messages

## How LLM attribution currently enters squashed commits

### Source 1: Existing trailers in original commits

When developers use AI coding tools (Claude Code, Copilot, etc.), those tools often append a `Co-Authored-By` trailer to each commit. The `squash.sh` script extracts and deduplicates all trailers (line 180–181) and the SKILL.md instructs the agent to preserve them. This means LLM attribution from original commits flows through to the squashed commit.

- **Decision**: Filter these in `squash.sh` using email-pattern matching before output
- **Rationale**: Filtering at the script level ensures consistent behavior regardless of which agent executes the skill
- **Alternatives considered**: Filtering only in SKILL.md instructions (rejected: relies on agent compliance, less reliable)

### Source 2: Agent adds its own attribution

AI coding tools typically add their own `Co-Authored-By` line when running `git commit`. The SKILL.md currently has no instruction preventing this.

- **Decision**: Add explicit instruction in SKILL.md Step 2 telling the agent not to add attribution
- **Rationale**: Direct instruction is the standard way to control agent behavior in skill files
- **Alternatives considered**: Adding a post-commit hook to strip trailers (rejected: over-engineered, not self-contained)

## LLM trailer identification strategy

- **Decision**: Use email-based pattern matching (not name-based)
- **Rationale**: Email addresses like `noreply@anthropic.com` are stable, unique identifiers. Name-based matching ("Claude", "GPT") risks false positives with human names.
- **Alternatives considered**:
  - Name-based matching (rejected: "Claude" is a common human name)
  - Allowlist approach — only keep known-human patterns (rejected: too restrictive, breaks for new collaborators)
  - Blocklist of specific full trailer strings (rejected: too brittle, breaks when model versions change)

## Known LLM/bot email patterns

| Pattern | Tool |
|---------|------|
| `noreply@anthropic.com` | Claude Code, Claude |
| `noreply@openai.com` | ChatGPT, OpenAI tools |
| `noreply@google.com` | Gemini, Google AI tools |
| `noreply@github.com` | GitHub Copilot |
| `users.noreply.github.com` | GitHub bot accounts (Dependabot, etc.) |

This list is extensible — new patterns can be added to the grep filter as new tools emerge.
