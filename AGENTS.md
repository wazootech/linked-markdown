# Agent Guide for Linked Markdown

## Style Guidelines

- **Rule:** Use ATX `#` headings only (no Setext underlines); wiki tooling does not index underlined headings for title, TOC, or fragment links.
- **Rule:** Use title-case H1 headings (page title; align with `headline` frontmatter). Use sentence-case H2+ headings (capitalize only the first word and proper nouns). Avoid numbered headings; keep headings concise and clear.
- **Rule:** Avoid using horizontal rules (`---`) for thematic breaks within page bodies.

## Project Structure

- **`spec/`** — The LMD specification (W3C JSON-LD CG work item)
- **`conformance/`** — Shared language-agnostic conformance test suite
- **`paper/`** — The academic paper describing LMD
- **`community/`** — W3C Community Group introduction materials
- **`examples/`** — Example LMD documents

## Specification

The LMD spec defines a single processor tier: **LMD-Extract**. A conforming processor parses frontmatter from a Linked Markdown document and returns `{ frontMatter, body, attrs }`.

See [spec/index.md](spec/index.md) for full details.
