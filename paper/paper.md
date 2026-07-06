---
title: "LMD: Linked Markdown — Markdown as Semantic Infrastructure"
author:
  - Ethan Davidson ($\texttt{ethan@wazoo.dev}$)
date: "2026"
arxiv:
  primary_category: cs.DL
  categories:
    - cs.DL
    - cs.SE
    - cs.IR
  license: CC_BY_4_0
  comments: "Full LMD specification included as Appendix A. 1 table."
zenodo:
  doi: 10.5281/zenodo.21216085
bibliography: references.bib
format:
  pdf:
    toc: true
    number-sections: true
  html:
    toc: true
    number-sections: true
---

# Abstract

**LMD (Linked Markdown)** is a specification for structuring,
validating, and querying typed Markdown documents as first-class semantic
graph nodes. An LMD document is simultaneously valid CommonMark and valid
JSON-LD --- rendering in any standard Markdown renderer while participating
in an RDF graph with SHACL validation, OWL-RL inference, and SPARQL query
capability. No custom syntax is introduced; the protocol lives entirely in
frontmatter and linking conventions. This paper presents LMD's design,
compares it with related approaches [@cagle2026databooks; @ozekik2023markdownld; @davay422026mdld; @iunera2025jsonldmarkdown], and describes the TypeScript and Python reference implementations.
The full specification is included as an appendix.

# Introduction

Markdown has become the de facto standard for writing across software,
documentation, knowledge management, and publishing. GitHub, Obsidian,
Notion, VS Code, Pandoc, and the CommonMark specification have made
`.md` files universal. However, Markdown documents remain opaque to
semantic tooling: they are strings, not typed entities with known
properties and relationships.

Existing approaches to adding semantics to Markdown fall into two camps:
inline annotation languages (e.g., Markdown-LD using Turtle in body text
[@ozekik2023markdownld], MD-LD using `{=iri}` syntax [@davay422026mdld])
and inference-based extraction (e.g., json-ld-markdown, which infers
Schema.org JSON-LD from document structure [@iunera2025jsonldmarkdown]).
Both approaches have limitations: inline annotations introduce nonstandard
syntax that can cause unpredictable rendering, while inference loses
author-intent semantics.

LMD takes a different approach: **frontmatter is JSON-LD**. The protocol
requires no custom syntax, no new file extension, and no special renderer.
A single `@id` and `@type` field in the frontmatter turns any Markdown
document into a typed RDF node. From this foundation, LMD layers
validation (SHACL), inference (OWL-RL), query (SPARQL), and publishing ---
each capability independently adoptable by conforming processors.

# LMD Design

## Zero custom syntax

LMD introduces no nonstandard Markdown syntax. All protocol semantics are
expressed through:

- Standard JSON-LD 1.1 frontmatter delimited by `---`
- Standard CommonMark links for document-level relationships
- Convention-based file organization (shapes, axioms, corpus structure)

A minimal LMD document is:

```yaml
---
"@id": https://example.org/docs/my-item
@type: schema:Article
@context:
  schema: https://schema.org/
---

# My Item
Content here.
```

This file is valid Markdown, valid YAML, and valid JSON-LD simultaneously.

## Document model

Every LMD document is identified by a canonical IRI (`"@id"`) and
one or more RDF types (`@type`). The `@id` and `@type` keywords
are also valid in YAML frontmatter. Frontmatter fields map directly
to RDF predicate-value pairs with the document's `@id` as subject. The
Markdown body (everything after the frontmatter) is addressable as an RDF
literal, typically via `schema:articleBody`.

Documents form a **corpus**: a collection of LMD documents sharing a
configuration, a shapes directory (for SHACL validation), and optional
axioms (for OWL-RL inference).

## Linking

Intra-corpus links use standard Markdown link syntax `[text](target.md)`.
A processor resolves the target filename to the target document's `@id` IRI.
External links (to IRIs outside the corpus) are preserved as typed RDF
object properties. Fragment identifiers (`#section-2`) may be typed as
`rdf:HTML` content.

## Validation and inference

LMD delegates validation to **SHACL 1.1** [@shacl].
Shapes are loaded from a `shapes/` directory in the corpus. Each shape
targets one or more document types via `sh:targetClass` and defines
property constraints (`sh:path`, `sh:datatype`, `sh:minCount`, etc.).

Shapes may also reference JSON Schema via `lmd:jsonSchema` for deep
structural validation of nested frontmatter.

Inference follows **OWL-RL** [@owl2rl] deductive reasoning --- enabling subclass
reasoning, property chain expansion, and domain/range inference.
Axioms are loaded from an `axioms/` directory. Processors may allow
clients to opt out of inference.

## Query and publishing

Corpora are queryable via **SPARQL 1.1** [@sparql11]. Documents may embed SPARQL
queries in fenced code blocks (`sparql`). Processors render query
results inline when generating output.

LMD processors may publish corpora as static HTML sites, with content
negotiation supporting HTML (browsers), JSON-LD (agents), and raw Markdown
(per Cloudflare Markdown for Agents convention).

# Prior Art and Related Work

| System | Approach | Syntax | RDF Compat |
|--------|----------|--------|------------|
| **DataBooks** [@cagle2026databooks] | Markdown as semantic infrastructure design pattern | YAML frontmatter | Partial (not native JSON-LD) |
| **Markdown-LD** [@ozekik2023markdownld] | Inline Turtle in Markdown body | Nonstandard `{}` annotations | Full RDF |
| **MD-LD** [@davay422026mdld] | Inline RDF via `{=iri}` syntax | Nonstandard `{=iri}` annotations | Full RDF |
| **json-ld-markdown** [@iunera2025jsonldmarkdown] | Schema.org inference from structure | None (inference-based) | JSON-LD output only |
| **LMD** (this paper) | JSON-LD frontmatter, SHACL validation, SPARQL query | Standard JSON-LD/YAML in frontmatter | Full RDF 1.1 |

**DataBooks** [@cagle2026databooks] is the closest intellectual precedent.
LMD adopts the DataBooks vision but diverges by requiring JSON-LD
frontmatter (not YAML) and zero custom inline syntax, enabling native RDF
integration without any transformation step.

**Markdown-LD** and **MD-LD** both embed RDF triples directly in Markdown
body text using custom annotation syntax. These approaches are complementary
to LMD: LMD addresses document-level typing and corpus-wide validation,
while inline annotation systems address triple-level granularity within a
single document. However, their nonstandard syntax can cause unpredictable
rendering in standard Markdown renderers, and they require editor plugins
or preprocessing.

**json-ld-markdown** infers Schema.org JSON-LD from plain Markdown structure
(headings, tables, lists). This is useful for SEO and consumption-oriented
pipelines, but inference necessarily loses information that only author-
intent typing can provide.

LMD differs from all prior work in three key ways:
1. Frontmatter is valid JSON-LD by construction, not converted to RDF
2. Validation and query are specified using W3C standards (SHACL, SPARQL)
3. Capabilities are layered (Core, Validation, Query, Publish) and independently adoptable

# Implementations

LMD has two reference implementations, both available as standard library
packages:

## Python implementation

[**`linked-markdown`**](https://pypi.org/project/linked-markdown/) on PyPI
([github.com/wazootech/linked-markdown-py](https://github.com/wazootech/linked-markdown-py))

An `extract()` function that parses LMD documents from a filesystem corpus,
resolving `@id` and `@type`, producing a JSON-LD dictionary in `.attrs`.
The resulting JSON-LD can be loaded directly into an `rdflib.Graph` for
SHACL validation (via `pyshacl`) and SPARQL 1.1 query execution.

Key architectural decisions include: zero required configuration beyond a
corpus root; automatic shape and axiom discovery from convention-based
directories; and strict separation of parsing, validation, query, and
publish into independently invocable CLI subcommands.

## TypeScript implementation

[**`@wazoo/linked-markdown`**](https://jsr.io/@wazoo/linked-markdown) on JSR
([github.com/wazootech/linked-markdown-ts](https://github.com/wazootech/linked-markdown-ts))

An `extract()` function returning a JSON-LD document in `.attrs`, compatible
with the `jsonld` npm package for RDF/JS quad production, SHACL validation,
and SPARQL query execution. Available for Deno, Node, Bun, and browser via CDN.

# Discussion

A central design choice is that LMD does not define its own vocabulary for general-purpose metadata. The `lmd:` namespace is reserved for protocol-layer concerns: document types, versioning, validation bindings, and provenance. For subject-matter properties, LMD documents use established vocabularies such as Schema.org, Dublin Core, FOAF, and PROV-O. This keeps the `lmd:` namespace small and scoped, and means LMD is not a competing vocabulary standard — it is a Markdown-compatible container in which those vocabularies live.

## Limitations

LMD currently requires JSON-LD knowledge for document creation. While
the default context provides commonly used prefixes (`schema`, `lmd`,
`rdf`, `rdfs`, `owl`, `sh`, `xsd`, `dc`, `foaf`, `prov`), authors must
understand basic RDF concepts (IRIs, types, predicates) to create typed
documents. Tooling improvements --- such as CLI scaffolding commands
(`wiki init`, `wiki new`) --- reduce this burden.

Interoperability with non-LMD Markdown tools is a deliberate design
constraint. Any CommonMark renderer can display an LMD document, but
only LMD processors can validate, query, or publish it. This is
acceptable: the protocol follows the robustness principle of being
liberal in what it accepts (any Markdown file with JSON-LD frontmatter)
and conservative in what it produces (valid RDF).

## Adoption path

LMD is incrementally adoptable. A single file with an `@id` and `@type`
in its frontmatter is a valid LMD document. Adding a shapes file enables
validation. Adding a SPARQL query enables query. Adding a publish
configuration enables HTML output. Each capability can be adopted
independently.

For existing Markdown corpora (Obsidian vaults, GitHub wikis, Jekyll
sites), adoption can begin with a single frontmatter field and grow
organically.

# Future Work

- **LMD Schema Registry**: A community-maintained registry of SHACL shapes
  for common document types (Person, Organization, Article, Book, etc.),
  analogous to Schema.org but expressed as SHACL.
- **Crawl and Federate**: Cross-corpus SPARQL federation enabling queries
  across multiple LMD-published sites.
- **lmd:scheme**: A dedicated URI scheme for LMD document resolution,
  potentially registered with IANA.
- **Interoperability Layer**: Bridge to other Markdown semantic systems
  (Markdown-LD, MD-LD) via SHACL shapes and RDF transformation pipelines.

# Conclusion

LMD demonstrates that Markdown can serve as a first-class semantic
infrastructure without sacrificing its core virtues: simplicity,
portability, and human readability. By restricting protocol semantics
to standard JSON-LD frontmatter and CommonMark links, LMD enables
typed, validatable, queryable Markdown documents that remain fully
compatible with existing tools and workflows.

The full specification follows in Appendix A.

# References

<!-- Bibliography is auto-generated by pandoc-citeproc from references.bib -->
<div id="refs"></div>

# Appendix A: LMD Specification

> This appendix contains the complete LMD specification, also available
> at `https://wazootech.github.io/linked-markdown/spec/`.

<!-- Spec content from spec/index.md -->

# Linked Markdown (LMD)

**Specification Version 0.1.0 -- Draft**

**Repository:** [github.com/wazootech/linked-markdown](https://github.com/wazootech/linked-markdown)
**Reference Implementations:**
- TypeScript: [`@wazoo/linked-markdown`](https://jsr.io/@wazoo/linked-markdown) on JSR ([github.com/wazootech/linked-markdown-ts](https://github.com/wazootech/linked-markdown-ts))
- Python: [`linked-markdown`](https://pypi.org/project/linked-markdown/) on PyPI ([github.com/wazootech/linked-markdown-py](https://github.com/wazootech/linked-markdown-py))
**License:** MIT

## Status of this document

This document was published by the [JSON for Linked Data Community Group](https://www.w3.org/groups/cg/json-ld/). It is a draft Editor's Draft and may be updated, replaced, or made obsolete by other documents at any time. It is inappropriate to cite this document as other than work in progress.

If you wish to make comments regarding this document, please [open an issue](https://github.com/wazootech/linked-markdown/issues) or contact the group on their public mailing list [public-json-ld@w3.org](mailto:public-json-ld@w3.org).

This document is governed by the [W3C Community Contributor License Agreement (CLA)](https://www.w3.org/community/about/process/cla/).

## 1. Introduction

Linked Markdown (LMD) is a specification for structuring typed Markdown documents as first-class semantic graph nodes.

LMD defines a protocol over standard `.md` files. An LMD document is simultaneously:

- **Valid Markdown** -- renderable by any CommonMark-compliant renderer, including GitHub, Obsidian, VS Code, and Pandoc.
- **Valid JSON-LD** -- frontmatter is a valid JSON-LD node, loadable by any RDF toolchain including `rdflib`, Apache Jena, and Oxigraph.
- **Incrementally adoptable** -- a single file with an `@id` field and an `@type` field is an LMD document. The protocol adds capability without breaking existing workflows.

No custom syntax is introduced. No new file extension is required. The protocol lives entirely in the frontmatter and linking conventions.

### 1.1. Design goals

1. **Zero custom syntax.** LMD adds no nonstandard Markdown syntax. All protocol semantics are expressed through standard JSON-LD frontmatter and standard Markdown links.
2. **Valid by default.** A vanilla `.md` file with JSON-LD frontmatter is valid LMD. The protocol does not require any special Markdown dialect.
3. **Layered capability.** A processor may parse or extract -- each capability builds on the previous.
4. **Standard RDF foundation.** LMD does not invent a new data model. It maps directly onto RDF 1.1 and JSON-LD 1.1.
5. **Deterministic structure.** Two conforming processors that process the same corpus produce the same results.

### 1.2. Table of contents

- [Introduction](#1-introduction)
  - [Design Goals](#11-design-goals)
  - [Prior Art and Related Work](#13-prior-art-and-related-work)
  - [Protocol Status and Versioning](#14-protocol-status-and-versioning)
- [Conformance](#2-conformance)
- [The LMD Document Model](#3-the-lmd-document-model)
- [Frontmatter as JSON-LD](#4-frontmatter-as-json-ld)
- [Document Linking](#5-document-linking)
- [Serialization](#6-serialization)
- [Security Considerations](#7-security-considerations)
- [IANA Considerations](#8-iana-considerations)

### 1.3. Prior art and related work

- **DataBooks (Cagle, Shannon, 2026)** -- A design pattern for Markdown as semantic infrastructure. LMD adopts the DataBooks vision but diverges by requiring JSON-LD frontmatter (not YAML) and zero custom inline syntax.
- **Markdown-LD (ozekik, 2023)** -- A literate programming approach to embedding Turtle in Markdown body text using inline RDF syntax. Complementary to LMD; LMD addresses document-level typing and validation rather than inline triple annotation.
- **MD-LD (davay42, 2026)** -- A zero-dependency JavaScript library for inline RDF annotations in Markdown using `{=iri}` syntax. The nonstandard annotation syntax can cause unpredictable rendering. LMD avoids this entirely by restricting protocol semantics to frontmatter.
- **json-ld-markdown (iunera, 2025)** -- A transformer that infers Schema.org JSON-LD from plain Markdown structure (headings, tables, lists). Addresses a different concern (SEO/consumption-oriented inference vs. LMD's author-intent typing).

### 1.4. Protocol status and versioning

This specification uses semantic versioning. Versions before 1.0.0 are drafts and may change incompatibly between minor versions. Once 1.0.0 is published, breaking changes require a major version bump.

## 2. Conformance

### 2.1. Document conformance

A document conforms to LMD if and only if:

1. It is a syntactically valid Markdown document per the CommonMark specification.
2. It contains exactly one JSON-LD frontmatter block delimited by `---` at the start of the file.
3. The frontmatter block is valid JSON-LD per [JSON-LD 1.1](https://www.w3.org/TR/json-ld11/).

The minimum viable LMD document:

```markdown
---
---
# My Item
Content here.
```

A processor MUST NOT reject a conforming LMD document for lacking optional fields such as `@id`, `@type`, `@context`, `name`, or `description`.

### 2.2. Processor conformance

A processor conforms to LMD if it implements the LMD-Extract capability:

- **LMD-Extract** -- Must parse frontmatter from a Linked Markdown document and return the extracted `frontMatter` string, `body` string, and `attrs` object (the parsed JSON-LD node). A processor MUST support all delimiter patterns listed in [§4.1](#41-syntax). A processor MUST reject malformed frontmatter with a descriptive error.

## 3. The LMD Document Model

### 3.1. Document identity

An LMD document SHOULD declare a canonical IRI in its `@id` field. When present, this IRI is the document's identity within the LMD corpus and serves as the RDF subject for all triples generated from the document's frontmatter.

The `@id` SHOULD be a dereferenceable HTTP(S) IRI. The `@id` MAY be a URN or tag URI for documents that are not publicly hosted.

```yaml
"@id": https://example.org/docs/people/alice-smith
```

### 3.2. Document type

An LMD document SHOULD declare its semantic type via `@type`. The value SHOULD be one or more IRI references, which may use CURIE notation when a `@context` is present.

```yaml
@type:
  - schema:Person
  - lmd:Document
```

### 3.3. The JSON-LD context

The `@context` field defines the prefix mappings for CURIE expansion within the frontmatter. A processor MUST resolve all CURIEs in the frontmatter against the active context before producing RDF.

The context MUST include at minimum:

```yaml
@context:
  schema: https://schema.org/
  lmd: https://wazootech.github.io/linked-markdown/ns#
```

Processors SHOULD provide a default context that includes commonly used prefixes (`schema`, `lmd`, `rdf`, `rdfs`, `xsd`, `dc`, `dcterms`, `foaf`). A document may override any default prefix.

### 3.4. Vocabulary conventions

The `lmd:` prefix defines terms specific to the LMD protocol layer -- document types and versioning. These terms describe a document's relationship to the LMD protocol rather than its subject matter.

For subject-matter and general-purpose metadata, documents SHOULD use established vocabularies such as Schema.org (`schema:`), Dublin Core (`dcterms:`), or FOAF (`foaf:`). A document that uses only standard vocabularies without any `lmd:`-prefixed properties is a valid LMD document. LMD does not replace existing vocabularies; it provides a Markdown-compatible substrate in which they coexist.

A processor MAY define equivalence mappings between `lmd:` terms and terms in other vocabularies to improve interoperability with non-LMD RDF consumers. Such mappings are processor-specific and not required for conformance.

### 3.5. Body content

The Markdown body text (everything after the frontmatter) is part of the LMD document. An LMD-Extract processor returns the body as a `body` string alongside the parsed frontmatter. A processor MUST NOT require body content. An LMD document may consist only of frontmatter.

### 3.6. Links as properties

Body links are not processed as RDF properties in this version of the protocol. A processor MUST NOT generate triples from body Markdown links. Link semantics may be addressed in a future version of the specification.

## 4. Frontmatter as JSON-LD

### 4.1. Syntax

Frontmatter MUST be a JSON-LD 1.1 document delimited by a supported delimiter pair. A processor MUST recognize the following delimiter patterns and their associated format expectations:

| Delimiter | Format | Closing Delimiter |
|-----------|--------|-------------------|
| `---` | YAML-family (YAML or JSON, since YAML is a JSON superset) | `---` |
| `---yaml` | YAML | `---` |
| `---json` | JSON | `---` |
| `---toml` | TOML | `---` |
| `+++` | TOML | `+++` |
| `= yaml =` | YAML (accepted, not recommended) | `= yaml =` |
| `= json =` | JSON (accepted, not recommended) | `= json =` |
| `= toml =` | TOML (accepted, not recommended) | `= toml =` |

The format hint determines how the processor parses the frontmatter content:
- **YAML-family**: processed with a YAML 1.x parser (which natively handles JSON).
- **JSON**: processed with a JSON parser.
- **TOML**: processed with a TOML parser.

A processor MUST reject frontmatter whose content cannot be parsed according to the indicated format:

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
"@id": https://example.org/doc
"@type": schema:Article
"@context":
  schema: https://schema.org/
name: Example Document
---

### 4.2. Fields

| Field | Type | Description |
|-------|------|-------------|
| `@id` | IRI | Canonical identifier for the document |
| `@type` | IRI or IRI[] | RDF type(s) of the document |
| `@context` | Object | CURIE prefix mappings |
| `name` | string | Human-readable title |
| `description` | string | Short summary (aim for 200 chars or less) |

A processor MUST NOT reject a conforming LMD document for lacking recommended fields.

### 4.4. CURIE resolution

When a `@context` is present, all CURIEs (e.g., `schema:Person`) in the frontmatter are expanded to full IRIs using the context's prefix map. A processor MUST reject a document containing unresolvable CURIEs when no matching prefix is defined.

### 4.5. Relation to RDF

Each frontmatter field that is not a JSON-LD keyword (`@id`, `@type`, `@context`) is mapped to an RDF predicate-value pair with the document's `@id` as the subject. Arrays become multiple triples with the same subject-predicate. Nested objects (when supported by the processor) become blank nodes or named nodes per JSON-LD 1.1 framing rules.

## 5. Document linking

Document-level link resolution is not part of this version of the protocol. A future version may define how intra-corpus links between LMD documents are resolved, validated, and exposed as RDF references.

## 6. Serialization

### 6.1. RDF compatibility

The `attrs` object returned by an LMD-Extract processor is a valid JSON-LD node. Consumers may load it into any JSON-LD 1.1-compatible library to produce RDF 1.1 triples:

- [jsonld.js](https://github.com/digitalbazaar/jsonld.js) (JavaScript / TypeScript)
- [rdflib](https://github.com/linkeddata/rdflib.js) (JavaScript / TypeScript)
- [rdflib](https://github.com/RDFLib/rdflib) (Python)
- [Apache Jena](https://jena.apache.org/) (Java)
- [Oxigraph](https://oxigraph.org/) (Rust / Python)

### 6.2. Context preservation

When the frontmatter includes a `@context`, a processor MUST preserve it in the returned `attrs` object so that downstream consumers can perform correct CURIE expansion and JSON-LD framing.

## 7. Security considerations

IRIs in `@id` and link targets MUST be validated to prevent injection of unexpected schemes (e.g., `javascript:`, `data:`). A processor SHOULD reject IRIs with non-http schemes.

## 8. IANA considerations

Linked Markdown does not currently require any IANA registrations. Future versions may request:
- A media type registration (e.g., `text/lmd` or `application/lmd+json`)
- A URI scheme registration (if a dedicated `lmd:` scheme is desired)

These considerations are deferred until the protocol reaches stability at version 1.0.0.

## Appendix A: complete LMD document example

```markdown
---
"@id": https://example.org/docs/people/alice-smith
"@type":
  - schema:Person
  - lmd:Document
"@context":
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
---

# Alice Smith

Alice is a senior software engineer at Example Corp.

## Biography

Alice has been building semantic web applications since 2020.

## Related

- See [Bob Jones](bob-jones.md) for a colleague
- See [Carol Davis](carol-davis.md) for another colleague
```

## Appendix B: LMD namespace

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

## Appendix C: Glossary

| Term | Definition |
|------|------------|
| LMD | Linked Markdown |
| Corpus | A collection of LMD documents sharing a configuration |
| Document | A single `.md` file with LMD-conforming frontmatter |
| Processor | Any tool or library implementing LMD-Extract |
| Frontmatter | The JSON-LD metadata block at the start of an LMD document |

## Appendix D: References

- [CommonMark Spec](https://spec.commonmark.org/) -- Standard Markdown syntax
- [JSON-LD 1.1](https://www.w3.org/TR/json-ld11/) -- JSON-based RDF serialization
- [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/) -- RDF data model

- [RFC 4151](https://www.rfc-editor.org/rfc/rfc4151) -- The 'tag' URI scheme
- [DataBooks: Markdown as Semantic Infrastructure](https://ontologist.substack.com/p/databooks-markdown-as-semantic-infrastructure) -- Cagle, Shannon 2026

*Repository: github.com/wazootech/linked-markdown-paper*
*Specification: github.com/wazootech/linked-markdown*
*TypeScript Implementation: github.com/wazootech/linked-markdown-ts*
*Python Implementation: github.com/wazootech/linked-markdown-py*
*DOI: [10.5281/zenodo.21216085](https://doi.org/10.5281/zenodo.21216085)*
