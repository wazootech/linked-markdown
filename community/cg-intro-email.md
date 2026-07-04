To: public-json-ld@w3.org
Subject: New CG work item: Linked Markdown (LMD) — JSON-LD frontmatter for typed Markdown documents

Hi all,

I'm Ethan Davidson, a new participant in the JSON for Linked Data Community
Group. I'd like to introduce a work item I've been developing:

**Linked Markdown (LMD)** — a specification for structuring,
validating, and querying typed Markdown documents as first-class semantic
graph nodes, using JSON-LD frontmatter.

https://wazootech.github.io/linked-markdown/spec/
https://github.com/wazootech/linked-markdown

The core idea: an LMD document is simultaneously valid CommonMark and valid
JSON-LD. A single `id` and `@type` field in the frontmatter turns any
Markdown file into a typed RDF node. From there, LMD layers validation
(SHACL), inference (OWL-RL), query (SPARQL), and publishing — each
capability independently adoptable.

No custom syntax is introduced — no new file extension, no inline annotation
language. The protocol lives entirely in standard JSON-LD frontmatter and
standard CommonMark links.

The YAML-LD work from this CG was a direct inspiration for taking JSON-LD
into the authoring/document space, and LMD aims to continue that direction
by making every `.md` file a valid, typed JSON-LD node.

I'd love feedback from the group and am happy to present in a future CG call
if there's interest.

Best,
Ethan Davidson
https://etok.me
