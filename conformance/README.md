---
"@id": https://wazootech.github.io/linked-markdown/conformance/
"@type": lmd:ConformanceSuite
lmd:version: 0.1.0
"@context":
  lmd: https://wazootech.github.io/linked-markdown/ns#
---

# Linked Markdown Conformance Suite

This directory contains the canonical language-agnostic conformance fixtures for Linked Markdown processors.

## Case Structure

Each case is a subdirectory of `cases/<case-id>/` containing:

| File | Purpose | Required |
|------|---------|----------|
| `input.md` | Raw Linked Markdown document to parse | Yes |
| `expected.json` | Expected result of `extract().attrs` (LMD-Parse) | For valid cases |
| `extracted.json` | Expected result of full `extract()` with `frontMatter`, `body`, and `attrs` (LMD-Extract) | For extract-tier cases |

Error cases omit `expected.json`/`extracted.json` and instead have an entry in `manifest.json` under `expect.error.code`.

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

## Valid Cases

### Delimiter Matrix (9 cases)

Each valid format-delimiter combination has an `input.md` that establishes `@id`, `@type`, `@context`, and `schema:name` in the appropriate syntax.

| Case | Opener | Closer | Format |
|------|--------|--------|--------|
| `valid-yaml-dash` | `---` | `---` | YAML |
| `valid-yaml-marker` | `---yaml` | `---` | YAML |
| `valid-yaml-equals` | `= yaml =` | `= yaml =` | YAML |
| `valid-json-dash` | `---` + JSON object | `---` | JSON |
| `valid-json-marker` | `---json` | `---` | JSON |
| `valid-json-equals` | `= json =` | `= json =` | JSON |
| `valid-toml-marker` | `---toml` | `---` | TOML |
| `valid-toml-plus` | `+++` | `+++` | TOML |
| `valid-toml-equals` | `= toml =` | `= toml =` | TOML |

### Edge Cases (6 cases)

| Case | Description |
|------|-------------|
| `canonical-type` | `@type` uses array syntax: `["schema:Article"]` |
| `body-links` | Markdown links in body are not included in parsed attrs |
| `missing-id` | Document without `@id` is valid (node lacks `@id`) |
| `missing-type` | Document without `@type` is valid (node lacks `@type`) |
| `valid-empty-frontmatter` | Empty frontmatter (`---\n---`) produces `frontMatter: ""` and `attrs: {}` |
| `bare-keywords-preserved` | Bare keywords `id`, `type`, `context` (no `@` prefix) are parsed as regular properties |
| `body-delimiter-ignored-by-parse` | Triple dashes in the body are not mistaken for a frontmatter delimiter |

### Encoding Cases (2 cases)

| Case | Description |
|------|-------------|
| `crlf-line-endings` | Frontmatter with CRLF line endings is normalized before parsing |
| `utf8-bom` | UTF-8 BOM at start of file is stripped before frontmatter parsing |

## Error Cases (8 cases)

Each error case MUST throw a `LinkedMarkdownError` with the specified error code.

| Case | Expected Code | Description |
|------|---------------|-------------|
| `missing-frontmatter` | `LMD_NO_FRONTMATTER` | No frontmatter delimiters at all |
| `invalid-unknown-marker` | `LMD_INVALID_FRONTMATTER` | Unknown marker `---bogus` |
| `invalid-malformed-yaml` | `LMD_INVALID_FRONTMATTER` | Invalid YAML content |
| `invalid-malformed-json` | `LMD_INVALID_FRONTMATTER` | Invalid JSON content |
| `invalid-malformed-toml` | `LMD_INVALID_FRONTMATTER` | Invalid TOML content |
| `invalid-non-object` | `LMD_INVALID_FRONTMATTER` | Content parses to a non-object (e.g., string) |
| `invalid-mismatched-delimiter` | `LMD_INVALID_FRONTMATTER` | Marker hints JSON but content is YAML |
| `invalid-no-closing-delimiter` | `LMD_INVALID_FRONTMATTER` | Opener exists but no closing delimiter found |

## Adding a Case

1. Create `cases/<case-id>/input.md` with the Linked Markdown content.
2. For valid cases, create `expected.json` with the expected `attrs` output.
3. For extract-tier cases, additionally create `extracted.json` with `{ "frontMatter": ..., "body": ..., "attrs": ... }`.
4. Add an entry in `manifest.json` under `cases` following the existing structure.
5. Run the conformance suite in both reference implementations:
   ```sh
   # TypeScript
   deno test --allow-read --allow-env=LMD_CONFORMANCE_ROOT test/conformance_test.ts
   
   # Python
   uv run pytest
   ```

## Reference Implementations

- **[TypeScript](https://github.com/wazootech/linked-markdown-ts)** — `@wazoo/linked-markdown` on JSR
- **[Python](https://github.com/wazootech/linked-markdown-py)** — `linked-markdown-py` on PyPI
