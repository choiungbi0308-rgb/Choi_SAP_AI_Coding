---
name: post-write
description: Run the Post-Write quality gate chain (SyntaxCheck → RunUnitTests → RunATCCheck) for the specified ABAP object. Use after any WriteSource or EditSource operation in Desktop App or Antigravity where hooks do not fire automatically.
argument-hint: "<object-name>"
allowed-tools: ["mcp__abap__SyntaxCheck", "mcp__abap__RunUnitTests", "mcp__abap__RunATCCheck"]
---

Load and apply the full Post-Write Mandatory Chain from `abap_vibe_coding/skills/post-write-chain/SKILL.md`.

Read the file at `abap_vibe_coding/skills/post-write-chain/SKILL.md` now and follow all instructions within it.

The object to run the chain on is: $ARGUMENTS

If $ARGUMENTS is empty, ask the user which object was last modified.
