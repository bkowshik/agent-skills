# agent-skills

> My personal collection of agent skills that actually help me.

It's built on the [Agent Skills Specification](https://agentskills.io/specification.md) (v1.0).

## Installation

```sh
npx skills add bkowshik/agent-skills
```

### Symlink for Claude Code

Skills are installed into `.agents/skills/`, but Claude Code currently looks for skills in `.claude/skills/`. To bridge the gap, create a symlink in your project:

```sh
mkdir -p .claude && ln -s ../.agents/skills .claude/skills
```

## Skills

| Skill | Description |
|-------|-------------|
| [squash-commits](skills/squash-commits/) | Combine all branch commits into a single commit with a synthesized message |
| [learning-log](skills/learning-log/) | Create a structured learning log entry from the current conversation |

## License

MIT
