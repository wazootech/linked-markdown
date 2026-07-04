---
id: https://wazootech.github.io/linked-markdown/spec/
"@type": lmd:Specification
lmd:version: 0.1.0
lmd:status: Draft
lmd:published: 2026-06-23
lmd:license: MIT
lmd:repository: https://github.com/wazootech/linked-markdown
lmd:supersedes: https://wazootech.github.io/wiki/
"@context":
  lmd: https://wazootech.github.io/linked-markdown/ns#
  schema: https://schema.org/
  dcterms: http://purl.org/dc/terms/
  xsd: http://www.w3.org/2001/XMLSchema#
  sh: http://www.w3.org/ns/shacl#
  owl: http://www.w3.org/2002/07/owl#
  prov: http://www.w3.org/ns/prov#
  rdf: http://www.w3.org/1999/02/22-rdf-syntax-ns#
  rdfs: http://www.w3.org/2000/01/rdf-schema#
---

# Linked Markdown (LMD)

**Specification Version 0.1.0 — Draft**

**Repository:** [github.com/wazootech/linked-markdown](https://github.com/wazootech/linked-markdown)
**Canonical Reference Implementation:** [github.com/wazootech/wiki](https://github.com/wazootech/wiki) (package `wazootech-wiki`, CLI command `wiki`)
**License:** MIT

## Status of This Document

This document was published by the [JSON for Linked Data Community Group](https://www.w3.org/groups/cg/json-ld/). It is a draft Editor's Draft and may be updated, replaced, or made obsolete by other documents at any time. It is inappropriate to cite this document as other than work in progress.

If you wish to make comments regarding this document, please [open an issue](https://github.com/wazootech/linked-markdown/issues) or contact the group on their public mailing list [public-json-ld@w3.org](mailto:public-json-ld@w3.org).

This document is governed by the [W3C Community Contributor License Agreement (CLA)](https://www.w3.org/community/about/process/cla/).

## 1. Introduction

Linked Markdown (LMD) is a specification for structuring, validating, and querying typed Markdown documents as first-class semantic graph nodes.

LMD defines a protocol over standard `.md` files. An LMD document is simultaneously:

- **Valid Markdown** — renderable by any CommonMark-compliant renderer, including GitHub, Obsidian, VS Code, and Pandoc.
- **Valid JSON-LD** — frontmatter is a valid JSON-LD node, loadable by any RDF toolchain including `rdflib`, Apache Jena, and Oxigraph.
- **Incrementally adoptable** — a single file with a `type` field and an `id` field is an LMD document. The protocol adds capability without breaking existing workflows.

No custom syntax is introduced. No new file extension is required. The protocol lives entirely in the frontmatter, the linking conventions, and the validation shapes applied by conforming processors.

LMD is the Worlds-aligned specification for defining item types, shapes, and orchestrating world memory within the Wazoo Worlds paradigm. It is the formalization of the design pattern described by DataBooks (Cagle, Shannon 2026) with the critical distinctions that LMD frontmatter is valid JSON-LD (not plain YAML) and LMD requires no inline annotation syntax.

### 1.1. Design Goals

1. **Zero custom syntax.** LMD adds no nonstandard Markdown syntax. All protocol semantics are expressed through standard JSON-LD frontmatter and standard Markdown links.
2. **Valid by default.** A vanilla `.md` file with JSON-LD frontmatter is valid LMD. The protocol does not require any special Markdown dialect.
3. **Layered capability.** A processor may validate, query, link-check, or publish — each capability is independent and optional at the processor level.
4. **Standard RDF foundation.** LMD does not invent a new data model. It maps directly onto RDF 1.1, JSON-LD 1.1, SHACL, OWL-RL, and SPARQL 1.1.
5. **Deterministic structure.** Two conforming processors that validate the same corpus against the same shapes produce the same results.

### 1.2. Table of Contents

- [Introduction](#1-introduction)
  - [Design Goals](#11-design-goals)
  - [Prior Art and Related Work](#13-prior-art-and-related-work)
  - [Protocol Status and Versioning](#14-protocol-status-and-versioning)
- [Conformance](#2-conformance)
- [The LMD Document Model](#3-the-lmd-document-model)
- [Frontmatter as JSON-LD](#4-frontmatter-as-json-ld)
- [Document Linking](#5-document-linking)
- [Validation](#6-validation)
- [Inference](#7-inference)
- [Query](#8-query)
- [Serialization](#9-serialization)
- [Publishing](#10-publishing)
- [Provenance](#11-provenance)
- [Security Considerations](#12-security-considerations)
- [IANA Considerations](#13-iana-considerations)

### 1.3. Prior Art and Related Work

- **DataBooks (Cagle, Shannon, 2026)** — A design pattern for Markdown as semantic infrastructure. LMD adopts the DataBooks vision but diverges by requiring JSON-LD frontmatter (not YAML) and zero custom inline syntax.
- **Markdown-LD (ozekik, 2023)** — A literate programming approach to embedding Turtle in Markdown body text using inline RDF syntax. Complementary to LMD; LMD addresses document-level typing and validation rather than inline triple annotation.
- **MD-LD (davay42, 2026)** — A zero-dependency JavaScript library for inline RDF annotations in Markdown using `{=iri}` syntax. The nonstandard annotation syntax can cause unpredictable rendering. LMD avoids this entirely by restricting protocol semantics to frontmatter.
- **json-ld-markdown (iunera, 2025)** — A transformer that infers Schema.org JSON-LD from plain Markdown structure (headings, tables, lists). Addresses a different concern (SEO/consumption-oriented inference vs. LMD's author-intent typing).

### 1.4. Protocol Status and Versioning

This specification uses semantic versioning. Versions before 1.0.0 are drafts and may change incompatibly between minor versions. Once 1.0.0 is published, breaking changes require a major version bump.

## 2. Conformance

### 2.1. Document Conformance

A document conforms to LMD if and only if:

1. It is a syntactically valid Markdown document per the CommonMark specification.
2. It contains exactly one JSON-LD frontmatter block delimited by `---` at the start of the file.
3. The frontmatter block is valid JSON-LD per [JSON-LD 1.1](https://www.w3.org/TR/json-ld11/).
4. The frontmatter block includes an `id` field whose value is an absolute IRI.
5. The frontmatter block includes a `@type` field (or the legacy `type` alias).

The minimum viable LMD document:

```markdown
---
id: https://example.org/docs/my-item
@type: schema:Article
@context:
  schema: https://schema.org/
---

# My Item
Content here.
```

A processor MUST NOT reject a conforming LMD document for lacking optional fields such as `@context`, `name`, or `description`.

### 2.2. Processor Conformance

A processor conforms to LMD if it implements at least one of the following capability tiers at the required conformance level:

- **LMD-Core** — Must parse frontmatter as JSON-LD, resolve `id` and `@type`, and produce an RDF 1.1 graph.
- **LMD-Validation** — Must implement SHACL validation per [SHACL 1.1](https://www.w3.org/TR/shacl/).
- **LMD-Query** — Must implement SPARQL 1.1 query execution against the LMD graph.
- **LMD-Publish** — Must produce static HTML output consistent with the LMD document's semantic content.

Tier identifiers are used for capability discovery. A processor may advertise: `Conforms-To: LMD-Core, LMD-Validation`.

### 2.3. Shape Conformance

A SHACL shapes graph conforms to LMD if it is valid SHACL per the W3C SHACL specification and targets at least one LMD document type via `sh:targetClass`.

## 3. The LMD Document Model

### 3.1. Document Identity

Every LMD document has a canonical IRI in its `id` (or `@id`) field. This IRI is the document's identity within the LMD corpus and serves as the RDF subject for all triples generated from the document's frontmatter.

The `id` SHOULD be a dereferenceable HTTP(S) IRI. The `id` MAY be a URN or tag URI for documents that are not publicly hosted.

```yaml
id: https://example.org/docs/people/alice-smith
```

### 3.2. Document Type

Every LMD document declares its semantic type via `@type` (or the legacy `type` alias). The value MUST be one or more IRI references, which may use CURIE notation when a `@context` is present.

```yaml
@type:
  - schema:Person
  - lmd:Document
```

### 3.3. The JSON-LD Context

The `@context` field defines the prefix mappings for CURIE expansion within the frontmatter. A processor MUST resolve all CURIEs in the frontmatter against the active context before producing RDF.

The context MUST include at minimum:

```yaml
@context:
  schema: https://schema.org/
  lmd: https://wazootech.github.io/linked-markdown/ns#
```

Processors SHOULD provide a default context that includes commonly used prefixes (`schema`, `lmd`, `rdf`, `rdfs`, `owl`, `sh`, `xsd`, `dc`, `dcterms`, `foaf`, `prov`). A document may override any default prefix.

### 3.4. Body Content

The Markdown body text (everything after the frontmatter) is part of the LMD document and is addressable as an RDF literal via the configured content predicate. The default content predicate is `schema:articleBody`.

A processor MAY include the body text as a literal triple in the document's RDF graph:
```
<id> schema:articleBody "Body text here..." .
```

A processor MUST NOT require body content. An LMD document may consist only of frontmatter.

### 3.5. Links as Properties

Standard Markdown links `[text](target)` in the body are interpreted as potential RDF object properties by a processor, but the protocol does not mandate automatic triple generation from arbitrary inline links. Only links whose semantic role is declared (via frontmatter, shape, or explicit convention such as `wikilinks` to other LMD documents) produce triples.

## 4. Frontmatter as JSON-LD

### 4.1. Syntax

Frontmatter MUST be a JSON-LD 1.1 document delimited by `---`. The frontmatter may use either JSON or YAML syntax, as YAML is a superset of JSON.

```markdown
---
{
  "@id": "https://example.org/doc",
  "@type": "schema:Article",
  "@context": {
    "schema": "https://schema.org/"
  },
  "schema:name": "Example Document"
}
---
```

YAML syntax is also conforming:

```yaml
---
id: https://example.org/doc
@type: schema:Article
@context:
  schema: https://schema.org/
name: Example Document
---
```

### 4.2. Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` or `@id` | IRI | Canonical identifier for the document |
| `type` or `@type` | IRI or IRI[] | RDF type(s) of the document |

### 4.3. Recommended Fields

| Field | Type | Description |
|-------|------|-------------|
| `@context` | Object | CURIE prefix mappings |
| `name` | string | Human-readable title |
| `description` | string | Short summary (aim for 200 chars or less) |

A processor MUST NOT reject a conforming LMD document for lacking recommended fields.

### 4.4. CURIE Resolution

When a `@context` is present, all CURIEs (e.g., `schema:Person`) in the frontmatter are expanded to full IRIs using the context's prefix map. A processor MUST reject a document containing unresolvable CURIEs when no matching prefix is defined.

### 4.5. Relation to RDF

Each frontmatter field that is not a JSON-LD keyword (`@id`, `@type`, `@context`) is mapped to an RDF predicate-value pair with the document's `id` as the subject. Arrays become multiple triples with the same subject-predicate. Nested objects (when supported by the processor) become blank nodes or named nodes per JSON-LD 1.1 framing rules.

## 5. Document Linking

### 5.1. Intra-Corpus Links

Links between LMD documents in the same corpus are expressed through Markdown links whose target is another LMD document's filename or IRI. When the target document exists in the corpus, the link is resolved to that document's `id` IRI.

```markdown
See [Alice Smith](Alice_Smith.md) for details.
```

A processor SHOULD verify that linked targets exist within the corpus and SHOULD report broken links as warnings or errors depending on processor configuration.

### 5.2. External Links

Links to IRIs outside the LMD corpus are treated as external references. A processor MAY resolve them but MUST NOT require resolution. External links are preserved as RDF object properties when the predicate is typed.

### 5.3. Fragment Identifiers

An LMD document may contain sections addressed by fragment identifier (e.g., `#section-2`). These fragments MAY be typed as `rdf:HTML` or `rdf:XMLLiteral` content within the document's RDF representation.

## 6. Validation

### 6.1. SHACL Validation

An LMD processor that supports validation MUST apply SHACL shapes loaded from the corpus's shapes directory against every LMD document. Validation follows the [SHACL 1.1](https://www.w3.org/TR/shacl/) specification:

- Compliance is determined by `sh:targetClass` matching the document's `@type`.
- Each shape defines property constraints (`sh:path`, `sh:datatype`, `sh:minCount`, `sh:maxCount`, `sh:pattern`, etc.).
- A shape may reference other shapes via `sh:node`.
- A shape may reference JSON Schema via `lmd:jsonSchema` (see 6.2).

### 6.2. JSON Schema Integration

An LMD shape MAY declare a JSON Schema binding via the `lmd:jsonSchema` property. When present, a processor MUST validate the frontmatter's JSON representation against the referenced JSON Schema. This enables validation of deeply nested structures that are awkward to express in SHACL alone.

```turtle
@prefix lmd: <https://wazootech.github.io/linked-markdown/ns#> .
@prefix sh: <http://www.w3.org/ns/shacl#> .

wiki:ContactShape a sh:NodeShape ;
    sh:targetClass wiki:Contact ;
    lmd:jsonSchema "contact.schema.json" .
```

### 6.3. Shape Location

Shapes are loaded from a directory declared in the corpus configuration. The default location is `shapes/` relative to the corpus root. Shapes may be in Turtle (`.ttl`), JSON-LD (`.jsonld`), or RDF/XML (`.rdf`) format.

## 7. Inference

### 7.1. OWL-RL Deductive Reasoning

An LMD processor that supports inference SHOULD apply OWL-RL deductive reasoning to expand the LMD corpus graph. The OWL-RL rule set is defined by [OWL 2 RL](https://www.w3.org/TR/owl2-profiles/#OWL_2_RL).

Inference enables subclass reasoning, property chain expansion, and domain/range inference:

```yaml
# document.md
---
id: wiki:alice-smith
@type: wiki:Engineer
---
```

With the axiom `wiki:Engineer rdfs:subClassOf schema:Person`, a reasoning processor infers `wiki:alice-smith a schema:Person`.

### 7.2. Custom Axioms

A processor MAY load custom axioms from the corpus. Axioms are Turtle or JSON-LD files that declare OWL class hierarchies, property chains, or SWRL-like rules. Axiom files live in the `axioms/` directory by default.

### 7.3. Opt-Out

A processor MUST allow clients to opt out of inference. The default inference mode is processor-specific.

## 8. Query

### 8.1. SPARQL 1.1

An LMD processor that supports query MUST implement SPARQL 1.1 Query Language and Protocol. Processors SHOULD support SELECT, CONSTRUCT, ASK, and DESCRIBE query forms.

### 8.2. Embedded Query Blocks

An LMD document may contain SPARQL query blocks embedded as fenced code blocks. These blocks are marked with the language tag `sparql`:

````markdown
```sparql
SELECT ?name ?email WHERE {
  ?person a schema:Person ;
          schema:name ?name ;
          schema:email ?email .
}
```
````

A processor MAY render the results of embedded queries inline (below the query block) when generating output. The processor MUST indicate where results begin and end with processor-specific comments to enable round-trip updates.

### 8.3. Result Formats

Query results SHOULD be representable in the following formats, at minimum: JSON, CSV, TSV, Markdown table, and HTML table. A processor determines the default result format.

## 9. Serialization

### 9.1. RDF Export

An LMD processor MUST be capable of exporting the LMD corpus graph in at least one of the following RDF serialization formats:

- JSON-LD 1.1 (compacted or expanded)
- Turtle (`.ttl`)
- RDF/XML (`.rdf`)

Processors SHOULD also support N-Triples, TriG, and N-Quads.

### 9.2. JSON-LD Export Specifics

When exporting as JSON-LD, a processor MUST preserve the document's `@context` in the output. The export MUST include all triples derived from the corpus, including those produced by inference (if inference was applied).

## 10. Publishing

### 10.1. Static HTML

An LMD processor that supports publishing SHOULD produce a static HTML site from the LMD corpus. The output MUST include:

- A page for each LMD document, with human-readable rendering of its content.
- Navigation between linked documents.
- A machine-readable representation of each document (JSON-LD, Turtle, etc.) linked from the HTML page.

### 10.2. URL Structure

Page URLs SHOULD be derived from the document's filename, minus the `.md` extension. A processor MAY support alternative URL styles (directory-style `/slug/` vs. file-style `/slug.html`).

### 10.3. Content Negotiation

A processor MAY support HTTP content negotiation, serving HTML to browsers and machine-readable formats (JSON-LD, Turtle) to agents. The `Accept: text/markdown` header SHOULD return the raw Markdown source, following the precedent established by Cloudflare Markdown for Agents.

## 11. Provenance

### 11.1. Process Stamps

LMD documents may include provenance metadata in their frontmatter, modeled after the PROV-O ontology. A process stamp records how a document was produced:

```yaml
lmd:provenance:
  lmd:transformer: lmd:cli
  lmd:inputs:
    - https://example.org/docs/source-doc
  lmd:timestamp: "2026-06-23T12:00:00Z"
  lmd:agent:
    @type: schema:Person
    schema:name: "Alice Smith"
```

### 11.2. PROV-O Alignment

Process stamps SHOULD align with the W3C PROV-O ontology:
- `lmd:provenance` maps to `prov:Activity`
- `lmd:inputs` maps to `prov:used`
- `lmd:agent` maps to `prov:wasAssociatedWith`
- The document itself is a `prov:Entity` generated by the activity

## 12. Security Considerations

### 12.1. IRI Injection

IRIs in `id`, `@id`, and link targets MUST be validated to prevent injection of unexpected schemes (e.g., `javascript:`, `data:`). A processor SHOULD reject IRIs with non-http schemes in publishing and query contexts.

### 12.2. Schema Loading

When loading shapes or axioms from remote IRIs, a processor SHOULD validate the remote content's media type and MAY refuse to load from untrusted sources.

### 12.3. SPARQL Injection

Embedded SPARQL blocks MUST be treated as untrusted input when loaded from untrusted corpora. A processor SHOULD apply read-only execution mode for embedded queries and MUST prevent CONSTRUCT or UPDATE operations that would modify the corpus.

## 13. IANA Considerations

Linked Markdown does not currently require any IANA registrations. Future versions may request:
- A media type registration (e.g., `text/lmd` or `application/lmd+json`)
- A URI scheme registration (if a dedicated `lmd:` scheme is desired)

These considerations are deferred until the protocol reaches stability at version 1.0.0.

---

## Appendix A: Complete LMD Document Example

```markdown
---
id: https://example.org/docs/people/alice-smith
@type:
  - schema:Person
  - lmd:Document
@context:
  schema: https://schema.org/
  lmd: https://wazootech.github.io/linked-markdown/ns#
  wiki: https://example.org/docs/
name: Alice Smith
description: Profile page for Alice Smith, software engineer.
schema:givenName: Alice
schema:familyName: Smith
schema:email: alice@example.com
schema:knows:
  - wiki:bob-jones
  - wiki:carol-davis
schema:jobTitle: Senior Software Engineer
lmd:provenance:
  lmd:transformer: lmd:cli
  lmd:timestamp: "2026-06-23T10:00:00Z"
  lmd:agent:
    @type: schema:Person
    schema:name: Alice Smith
---

# Alice Smith

Alice is a senior software engineer at Example Corp.

## Biography

Alice has been building semantic web applications since 2020.

## Related

- See [Bob Jones](bob-jones.md) for a colleague
- See [Carol Davis](carol-davis.md) for another colleague
```

---

## Appendix B: LMD Namespace

The `lmd:` prefix expands to `https://wazootech.github.io/linked-markdown/ns#`. The following terms are defined:

| Term | Description |
|------|-------------|
| `lmd:Document` | The base type for all LMD documents |
| `lmd:Specification` | The type for the LMD specification document |
| `lmd:version` | The LMD specification version a document targets |
| `lmd:status` | The document's protocol status (Draft, Stable, Deprecated) |
| `lmd:published` | The document's publication date |
| `lmd:license` | The document's license IRI |
| `lmd:repository` | The document's canonical repository |
| `lmd:supersedes` | An IRI this specification replaces |
| `lmd:jsonSchema` | Links a SHACL shape to an external JSON Schema file |
| `lmd:provenance` | Provenance / process stamp metadata |
| `lmd:transformer` | The tool or agent that produced the document |
| `lmd:inputs` | Input documents used to produce the document |
| `lmd:timestamp` | The production timestamp |
| `lmd:agent` | The agent responsible for production |

---

## Appendix C: Glossary

| Term | Definition |
|------|------------|
| LMD | Linked Markdown |
| Corpus | A collection of LMD documents sharing a configuration |
| Document | A single `.md` file with LMD-conforming frontmatter |
| Shape | A SHACL constraint definition for validating document structure |
| Axiom | A set of OWL or SWRL rules for deductive reasoning |
| Processor | Any tool or library implementing one or more LMD tiers |
| Frontmatter | The JSON-LD metadata block at the start of an LMD document |

---

## Appendix D: References

- [CommonMark Spec](https://spec.commonmark.org/) — Standard Markdown syntax
- [JSON-LD 1.1](https://www.w3.org/TR/json-ld11/) — JSON-based RDF serialization
- [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/) — RDF data model
- [SHACL 1.1](https://www.w3.org/TR/shacl/) — Shapes Constraint Language
- [OWL 2 RL](https://www.w3.org/TR/owl2-profiles/) — OWL 2 RL profile
- [SPARQL 1.1](https://www.w3.org/TR/sparql11-query/) — SPARQL query language
- [PROV-O](https://www.w3.org/TR/prov-o/) — Provenance ontology
- [RFC 4151](https://www.rfc-editor.org/rfc/rfc4151) — The 'tag' URI scheme
- [DataBooks: Markdown as Semantic Infrastructure](https://ontologist.substack.com/p/databooks-markdown-as-semantic-infrastructure) — Cagle, Shannon 2026
