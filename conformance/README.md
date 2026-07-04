---
id: https://wazootech.github.io/linked-markdown/conformance/
"@type": lmd:ConformanceSuite
lmd:version: 0.1.0
"@context":
  lmd: https://wazootech.github.io/linked-markdown/ns#
---

# Linked Markdown Conformance Suite

This directory contains the canonical language-agnostic conformance fixtures for Linked Markdown processors.

Implementation repositories should consume this suite and provide a thin native harness that reads `manifest.json`, parses each `input.md`, and compares normalized outputs against the expected files.

## Contracts

- Compare normalized parsed JSON, not implementation-specific objects.
- Compare RDF as sorted N-Triples for cases without blank nodes.
- Assert stable error codes, not exact human-facing error messages.
- Treat file paths in `manifest.json` as relative to this `conformance/` directory.

## Suggested CLI Contract

Processors may expose this black-box interface for conformance testing:

```sh
lmd parse input.md --format json
lmd rdf input.md --format nt
lmd validate input.md --format json
```
