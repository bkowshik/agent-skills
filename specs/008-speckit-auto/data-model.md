# Data Model: Speckit Auto

**Feature**: 008-speckit-auto | **Date**: 2026-03-26

## Overview

This skill has no persistent data model. It orchestrates existing speckit commands that each manage their own artifacts on disk. The "state" of a pipeline run is implicit in which artifacts exist in the feature's `specs/` directory.

## Pipeline Step Sequence

The pipeline executes these steps in order. Each step's completion is determined by the existence of its output artifacts.

| Step | Command | Output Artifacts | Completion Signal |
|------|---------|-----------------|-------------------|
| 1 | `/speckit.specify` | `specs/{feature}/spec.md` | spec.md exists and has content |
| 2 | `/speckit.clarify` | Updates `specs/{feature}/spec.md` (adds Clarifications section) | Clarifications section present in spec.md |
| 3 | `/speckit.plan` | `specs/{feature}/plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/` | plan.md exists |
| 4 | `/speckit.tasks` | `specs/{feature}/tasks.md` | tasks.md exists |
| 5 | `/speckit.analyze` | Console output (read-only audit) | No inconsistencies reported, or auto-fix applied |
| 6 | `/speckit.implement` | Source code files in repository | Implementation tasks marked complete |

## Artifact Dependency Graph

```
specify → spec.md
              ↓
         clarify → spec.md (updated)
              ↓
          plan → plan.md, research.md, data-model.md, quickstart.md, contracts/
              ↓
         tasks → tasks.md
              ↓
       analyze → (validates spec.md + plan.md + tasks.md consistency)
              ↓
     implement → source code files
```

## State Transitions

A pipeline run progresses through these states implicitly:

```
NOT_STARTED → SPECIFY → CLARIFY → PLAN → TASKS → ANALYZE → IMPLEMENT → COMPLETED
                                                                    ↓
                                                                 FAILED (at any step)
```

State is not persisted -- it's determined by examining which artifacts exist on disk when resuming.
