### New work item: Linked Markdown (LMD)

**Spec:** https://wazootech.github.io/linked-markdown/spec/
**Repo:** https://github.com/wazootech/linked-markdown
**Proposed by:** Ethan Davidson (https://etok.me)

LMD is a specification for structuring, validating, and querying typed
Markdown documents as first-class semantic graph nodes. Every LMD document
is simultaneously valid CommonMark and valid JSON-LD 1.1 — `id` + `@type`
in the frontmatter turns any `.md` file into a typed RDF node.

The protocol uses JSON-LD frontmatter (no custom inline syntax) and layers
SHACL validation, OWL-RL inference, SPARQL query, and static site publishing
as independently adoptable capabilities.

This was inspired in part by the CG's YAML-LD work and extends the same
philosophy into the Markdown/document authoring space.

Would the CG be interested in adopting this as a work item? Happy to present
on a call or discuss on the mailing list.
