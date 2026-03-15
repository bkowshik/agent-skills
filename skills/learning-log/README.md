# learning-log

Create a structured learning log entry from the current conversation. Distills key concepts, worked examples, and insights into a well-organized Markdown file.

## Install

```bash
npx skills add bkowshik/git-skills
```

## Usage

After a conversation where you learned something:

```
/learning-log                          # capture all topics from the conversation
/learning-log AUROC computation        # focus on a specific topic
/learning-log the bug we just debugged # natural language reference
```

The agent will:
1. Analyze the conversation (filtered to the specified topic if provided)
2. Generate a structured Markdown entry with YAML frontmatter
3. Save it to `learning-log/YYYY-MM-DD-slug.md` (today's date, slug derived from topic)
4. Optionally update related entries with bidirectional links

If no topic is specified and the conversation covered multiple unrelated topics, the agent will ask which one(s) to log.

## Entry structure

Each entry includes:
- **YAML frontmatter**: date, title, tags, related entries
- **What I Learned**: Core concepts with worked examples
- **Key Insight**: The most important takeaway and project implications
- **Sources**: Referenced papers, docs, and URLs

## Requirements

- A `learning-log/` directory in your repository (created automatically if missing)
