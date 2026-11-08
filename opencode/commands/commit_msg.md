---
description: Review repository changes and create a commit message
---

Check the current working directory for Git repository changes.

1. Run `git status --short`.
2. If there are no changes, tell me there is nothing to commit and stop.
3. Run `git diff` for unstaged changes and `git diff --cached` for staged changes.
4. Review the changes in context of the repository.
5. Propose a Conventional Commit message:
   - Format: `type(optional scope): short summary`
   - Use imperative present tense, lowercase, no final period
   - Keep the first line under 50 characters
   - Include concise bullet points only if they add useful context
6. Show me the proposed message and ask whether to commit.
7. If I approve, run `git add -A` only if needed, then `git commit -m "<message>"`.
8. If there are merge conflicts, do not resolve them; stop and explain the conflict.

