---
name: learning-log
description: >-
  Create a structured learning log entry from the current conversation. Distills
  what was discussed into a well-organized Markdown file with YAML frontmatter,
  clear explanations, worked examples, and source links. Use after a teaching
  or exploration conversation to capture insights before they're lost. Trigger
  keywords: learning log, capture learning, log what I learned, save learning,
  journal entry, write up what we discussed.
---

# Learning Log

Create a high-quality learning log entry from the current conversation. The
entry distills the key concepts discussed into a structured Markdown file that
serves as a durable reference.

## When to use

After a conversation where you learned something — a concept explanation, a
debugging session that revealed how something works, a deep dive into a domain
topic, or an exploration of a technique. The goal is to capture the insight
while the context is fresh.

## User input

The user may provide input to scope what gets logged. This is especially useful
when a conversation covered multiple topics but the user only wants to capture
one.

**Examples:**
- `/learning-log` — no input: analyze the full conversation and capture all
  learnable topics. If multiple unrelated topics exist, ask the user which
  one(s) to log (or create separate entries for each).
- `/learning-log AUROC computation` — topic specified: focus only on the parts
  of the conversation about AUROC computation, ignore unrelated discussion.
- `/learning-log the batch norm bug we debugged` — natural language reference
  to a specific part of the conversation.
- `/learning-log tags: deep-learning, debugging` — user provides custom tags
  to use.

When input is provided, treat it as a filter: scan the conversation for the
relevant portions and build the entry from those parts only. Do not include
content from unrelated parts of the conversation.

## Entry format

Every entry follows this structure:

```yaml
---
date: YYYY-MM-DD
title: "Short descriptive title"
tags:
  - lowercase-kebab-case-tag
related: []
---

## What I Learned

Core concepts and explanations. Use subsections (### headings) if multiple
related topics were covered. Include worked examples with concrete numbers
where the conversation had them.

## Key Insight

The most important takeaway — what changes how you think about the problem
or what you'll do differently. Connect it to the project context if relevant.

## Sources

- [Source title](URL)
```

## Workflow

### Step 1: Analyze the conversation

Review the current conversation and identify:

- **Core concepts taught or discovered** — what was the main thing learned?
- **Worked examples** — any concrete calculations, code snippets, or step-by-step
  demonstrations that make the concept tangible
- **Connections and implications** — how does this relate to the project or
  change how a problem should be approached?
- **Sources referenced** — any papers, documentation, or URLs mentioned

If the conversation covered multiple related topics, plan to organize them as
subsections under "What I Learned" (use `### Numbered headings`).

### Step 2: Determine metadata

- **date**: Use today's date (YYYY-MM-DD)
- **title**: Write a concise title that captures the scope. If multiple topics,
  use a title that ties them together (e.g., "AUROC: Pairwise Computation, the
  Ranking Trick, and Clinical Pitfalls")
- **tags**: Pick 2-5 lowercase kebab-case tags covering the topic areas.
  Check existing entries for tag reuse:
  ```bash
  grep -rh "^  - " learning-log/*.md 2>/dev/null | sort -u
  ```
- **related**: Check if any existing entries cover related topics:
  ```bash
  ls learning-log/*.md 2>/dev/null
  ```
  Add filenames of related entries if found.

### Step 3: Generate the filename

Format: `YYYY-MM-DD-descriptive-slug.md`

- Slug should be lowercase, hyphen-separated, max ~5 words
- Should capture the main topic for scannability when browsing via `ls`

### Step 4: Write the entry

Write the entry to `learning-log/<filename>`. Follow these quality guidelines:

**What I Learned section:**
- Lead with the concept, not the conversation. Write as if explaining to your
  future self who has forgotten the context.
- Preserve worked examples from the conversation with concrete numbers — these
  are the most valuable part for future reference.
- Use code blocks for calculations, data tables, formulas, and code snippets.
- If multiple topics were covered, use `### Numbered` subsections (e.g.,
  `### 1. Topic name`).
- Keep explanations dense but clear. Cut conversational filler.
- Include enough context that the entry is self-contained — a reader shouldn't
  need the original conversation.

**Key Insight section:**
- State the single most important takeaway.
- Connect it to the project or problem at hand — why does this matter for what
  you're building?
- If there are actionable implications (e.g., "this means we should use X
  instead of Y"), state them explicitly.

**Sources section:**
- Include any papers, documentation, Wikipedia links, or URLs referenced.
- Use descriptive link text, not bare URLs.
- Only include sources that were actually referenced or are directly relevant.

### Step 5: Update related entries (if applicable)

If the new entry references existing entries in its `related` field, consider
adding a bidirectional link — update the referenced entry's `related` field
to include the new entry's filename.

Only do this if the relationship is strong and navigating in both directions
would be useful.

### Step 6: Confirm creation

After writing, show the user:
- The file path created
- The title and tags
- A brief note on what was captured

## Quality checklist

Before saving, verify:
- [ ] Title is descriptive and concise
- [ ] Tags are lowercase kebab-case and reuse existing tags where appropriate
- [ ] Worked examples from the conversation are preserved with concrete numbers
- [ ] Explanations are self-contained (no "as we discussed" references)
- [ ] Key Insight connects the learning to the project context
- [ ] Sources have descriptive link text
- [ ] YAML frontmatter is valid

## Edge cases

- **Conversation had no clear learning**: Tell the user there's nothing
  substantial to log. Don't create empty or thin entries.
- **Multiple unrelated topics**: Create separate entries for each topic rather
  than one sprawling entry. Each should be independently useful.
- **No learning-log directory exists**: Create the directory and a `_template.md`
  with the full entry structure:
  ```bash
  mkdir -p learning-log
  cat > learning-log/_template.md << 'EOF'
  ---
  date: YYYY-MM-DD
  title: "Short descriptive title"
  tags:
    - lowercase-kebab-case-tag
  related: []
  ---

  ## What I Learned

  Core concepts and explanations.

  ## Key Insight

  The most important takeaway.

  ## Sources

  - [Source title](URL)
  EOF
  ```
- **User provides additional context**: If the user passes arguments (e.g.,
  specific topic to focus on, custom tags), incorporate them.

## Example

A conversation covered how batch normalization works, why it helps training,
and a subtle bug where eval mode wasn't set during inference:

```
File: learning-log/2026-03-20-batch-norm-eval-mode-bug.md

---
date: 2026-03-20
title: "Batch Normalization: How It Works and the Eval Mode Trap"
tags:
  - deep-learning
  - debugging
  - training
related: []
---

## What I Learned

### 1. How batch normalization works
[Clear explanation with the formula and concrete example...]

### 2. The eval mode bug
[What went wrong, why, and how it was fixed...]

## Key Insight
[Why this matters for the project...]

## Sources
- [Ioffe & Szegedy (2015): Batch Normalization](https://arxiv.org/abs/1502.03167)
```
