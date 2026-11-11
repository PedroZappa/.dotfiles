---
description: Explain complex concepts at three levels of understanding
---

Explain the following concept: $ARGUMENTS

Structure your explanation into these sections:

## 1. Explain Like I'm a Child
- Use very simple language.
- Avoid technical jargon.
- Explain the fundamental idea using familiar everyday objects or experiences.
- Focus on helping me understand WHAT it is and WHY it exists.

## 2. Explain Like I'm a Normal Adult
- Assume I am an intelligent adult with general knowledge but no specialised expertise in this subject.
- Introduce the relevant terminology and explain it clearly.
- Explain how it works, why it matters, and where it is used.
- Build the explanation logically, step by step.

## 3. Explain Like I'm an Expert
- Provide a technically rigorous explanation.
- Introduce the underlying principles, mechanisms, mathematics, algorithms, or architecture where relevant.
- Explain important implementation details, limitations, trade-offs, and edge cases.
- Use correct technical terminology.
- Include equations, code examples, diagrams, or references where they genuinely improve understanding.

## 4. A Metaphor That Connects Everything
- Create one intuitive, memorable metaphor that captures the core concept.
- Explain how each part of the metaphor maps to the actual technical concept.
- Make sure the metaphor is accurate enough to reinforce understanding without introducing misconceptions.

## 5. Connect the Levels
- Explain how the simple explanation relates to the expert explanation.
- Identify the fundamental idea that remains consistent across all three levels.
- Highlight the most important insight I should remember.

## Teaching Guidelines
- Prioritise understanding over brevity.
- Never assume I understand a technical term just because you introduced it.
- Explain unfamiliar terminology when it first appears.
- Use practical examples wherever possible.
- If the concept involves mathematics, explain the intuition before introducing equations.
- If the concept involves programming, include relevant code examples when useful.
- Distinguish established facts from simplifications or analogies.
- Do not sacrifice technical accuracy to make something easier to understand.

## 6. Obsidian Note
After completing the explanation above, turn the given information into a well-formatted Obsidian note:

- Include the full content of all three explanations (child, normal person, expert) as their own sections in the note — do not summarise, merge, or shorten them.
- Keep the metaphor and the "connect the levels" sections in full as well.
- Reformat the content using Obsidian-friendly Markdown:
  - A single `# H1` title naming the concept.
  - YAML frontmatter at the top with `tags`, `created` (today's date), and relevant `aliases`.
  - Use `[[wikilinks]]` for key concepts and terms that could link to other notes.
  - Use callouts (`> [!summary]`, `> [!info]`, etc.) where they add value, e.g. for the metaphor or the key insight.
  - Give each level its own heading (e.g. `## Explain Like I'm a Child`, `## Explain Like I'm a Normal Person`, `## Explain Like I'm an Expert`).
- Show the note to me, then ask me whether I want to save it to a file.
- If I agree, save it in an appropriate folder in the current working directory (create a folder such as `notes/`, `obsidian/`, or a topic-matching subfolder if none fits), named after the concept in Title Case (e.g. `My Concept.md`).
- If a file with that name already exists, ask me whether to overwrite it, pick a new name, or cancel.
- Confirm the saved path when done.

