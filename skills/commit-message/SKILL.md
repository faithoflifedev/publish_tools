---
name: commit-message
description: Updates the tool/publish_tools.yaml file to record the commit message and change summary for the next release using conventional commit format.
metadata:
  version: "1.0"
---

# commit-message

Updates the `tool/publish_tools.yaml` file used by the [`publish_tools`](https://pub.dev/packages/publish_tools) Dart package to record the commit message and change summary for the next release.

## File format

```yaml
commit: "type(scope): short summary"
changes: |
  * type(scope): change description
  * type(scope): change description
```

- `commit` — a single conventional commit subject line (≤72 chars, quoted)
- `changes` — a YAML block scalar (`|`) with one `* ` prefixed bullet per logical change

## Workflow

1. Review recent changes in the project:
   - Check `git diff HEAD` or `git log --oneline` for uncommitted/recent work
   - Review any modified files the user described in the conversation
2. Determine the highest-impact conventional commit type for the `commit` field:
   - `feat` — new feature or capability added
   - `fix` — bug fix
   - `docs` — documentation only
   - `refactor` — code change with no feature/fix
   - `chore` — dependency bumps, tooling, config
   - `test` — tests added or updated
3. Write the `commit` line: `"type(optional-scope): concise summary"`
4. Write one bullet per logical change in the `changes` block. Use the same conventional commit prefixes. Order: `feat` first, then `fix`, `docs`, `refactor`, `chore`, `test`.
5. Overwrite the existing content of `tool/publish_tools.yaml` with the new values.

## Gotchas

- The `changes` value uses a YAML literal block scalar (`|`). Every bullet must be indented by exactly 2 spaces and prefixed with `* `.
- The `commit` value must be quoted if it contains a colon.
- In a monorepo, each package has its own `tool/publish_tools.yaml` — update them separately with package-scoped commit messages (e.g. `feat(easy_onvif): …`).
- Do not bump the version in `pubspec.yaml` — `publish_tools` handles that as a separate step.

## Example output

```yaml
commit: "feat(easy_onvif): add AI agent skills to package"
changes: |
  * feat: add skills/ directory with 7 Agent Skills for AI coding assistants
  * feat: add references/ subdirectories with method reference tables
  * docs: add AI Agent Skills section to README
  * fix: remove experimental package:xml/xpath.dart import from tests
```
