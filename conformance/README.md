---
"@id": https://wazootech.github.io/linked-markdown/conformance/
"@type": lmd:ConformanceSuite
lmd:version: 0.1.0
"@context":
  lmd: https://wazootech.github.io/linked-markdown/ns#
---

# Linked Markdown Conformance Suite

This directory contains the canonical language-agnostic conformance fixtures for Linked Markdown processors.

Implementation repositories should consume this suite and provide a thin native harness that reads `manifest.json`, parses each `input.md`, and compares normalized outputs against the expected files.

## Conformance Tiers

| Tier | Covers | Tests |
|------|--------|-------|
| LMD-Parse | `extract().attrs` | Extract the JSON-LD node from frontmatter; error on malformed delimiters or non-object attrs. |
| LMD-Extract | Full `extract()` return | Same as LMD-Parse plus `frontMatter` string and `body` string fidelity. |

A processor that passes all LMD-Parse cases is a conforming Linked Markdown parser. A processor that additionally passes all LMD-Extract cases is a conforming Linked Markdown extractor.

## Contracts

- Compare normalized parsed JSON, not implementation-specific objects.
- For LMD-Extract, compare `frontMatter`, `body`, and `attrs` separately.
- Assert stable error codes for error cases via `expect.error.code`.
- Treat file paths in `manifest.json` as relative to this `conformance/` directory.
- An `expect.error.code` entry indicates the case MUST throw the named `LinkedMarkdownError` code.

## Delimiter Reference

| Case ID pattern | Opener | Closer | Format |
|-----------------|--------|--------|--------|
| `valid-yaml-dash` | `---` | `---` | YAML |
| `valid-yaml-marker` | `---yaml` | `---` | YAML |
| `valid-yaml-equals` | `= yaml =` | `= yaml =` | YAML |
| `valid-json-dash` | `---` + JSON object | `---` | JSON |
| `valid-json-marker` | `---json` | `---` | JSON |
| `valid-json-equals` | `= json =` | `= json =` | JSON |
| `valid-toml-marker` | `---toml` | `---` | TOML |
| `valid-toml-plus` | `+++` | `+++` | TOML |
| `valid-toml-equals` | `= toml =` | `= toml =` | TOML |
