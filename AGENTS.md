# Agent Guide for Linked Markdown

This repository is the **specification home of Linked Markdown (LMD)**: the
normative spec, the shared conformance suite, and community materials. It has
no runnable test suite of its own — verification happens in the language
implementations that consume `conformance/`, which mirror their CI exactly.

## Verification

Run the conformance suites from the implementation repos, not here:

- **`repos/linked-markdown-ts`** (Deno):
  `deno fmt --check && deno lint && deno task check && deno task test`
- **`repos/linked-markdown-py`** (uv/pytest):
  `uv run ruff format --check && uv run ruff check && uv run pytest`

If a spec change is under review, run both suites against a branch that
consumes the updated spec before landing it.

## Style guidelines

- **Rule:** Use ATX `#` headings only (no Setext underlines); wiki tooling does not index underlined headings for title, TOC, or fragment links.
- **Rule:** Use title-case H1 headings (page title; align with `headline` frontmatter). Use sentence-case H2+ headings (capitalize only the first word and proper nouns). Avoid numbered headings; keep headings concise and clear.
- **Rule:** Avoid using horizontal rules (`---`) for thematic breaks within page bodies.

## Project structure

- **`spec/`** — The LMD specification (W3C JSON-LD CG work item)
- **`conformance/`** — Shared language-agnostic conformance test suite
- **`paper/`** — The academic paper describing LMD
- **`community/`** — W3C Community Group introduction materials
- **`examples/`** — Example LMD documents

## Specification

The LMD spec defines a single processor tier: **LMD-Extract**. A conforming processor parses frontmatter from a Linked Markdown document and returns `{ frontMatter, body, attrs }`.

See [spec/index.md](spec/index.md) for full details.
