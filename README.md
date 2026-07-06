# Linked Markdown

[![JSR](https://jsr.io/badges/@wazoo/linked-markdown)](https://jsr.io/@wazoo/linked-markdown)
[![PyPI version](https://badge.fury.io/py/linked-markdown.svg)](https://pypi.org/project/linked-markdown/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A specification for structuring, validating, and querying typed Markdown documents as first-class semantic graph nodes.

### Installation

```sh
# Python
pip install linked-markdown
```

```sh
# TypeScript (Deno)
deno add jsr:@wazoo/linked-markdown

# TypeScript (Node)
npx jsr add @wazoo/linked-markdown
```

### RDF Compatibility

The `attrs` returned by `extract()` is valid JSON-LD, directly loadable into the standard RDF library of your choice:

**Python** — uses `rdflib`:

```python
import json
import rdflib
from linked_markdown import extract

result = extract(markdown)
g = rdflib.Graph()
g.parse(data=json.dumps(result.attrs), format="json-ld")
```

**TypeScript** — uses `jsonld`:

```ts
import jsonld from "jsonld";
import { extract } from "@wazoo/linked-markdown";

const result = extract(markdown);
const quads = await jsonld.toRDF(result.attrs);
```

- **[spec/](./spec/)** — The LMD specification (W3C JSON-LD CG work item)
- **[conformance/](./conformance/)** — Shared language-agnostic conformance test suite
- **[paper/](./paper/)** — arXiv tech report: "LMD: Linked Markdown — Markdown as Semantic Infrastructure"
- **[community/](./community/)** — W3C Community Group introduction materials
- **[Reference implementation (TypeScript)](https://github.com/wazootech/linked-markdown-ts)** — `@wazoo/linked-markdown` on JSR
- **[Reference implementation (Python)](https://github.com/wazootech/linked-markdown-py)** — `linked-markdown` on PyPI
