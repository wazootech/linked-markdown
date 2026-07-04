---
title: "LMD: Linked Markdown — Markdown as Semantic Infrastructure"
author:
  - Ethan Davidson ($\texttt{ethan@wazoo.dev}$)
date: "2026"
arxiv:
  primary_category: cs.SE
  categories:
    - cs.SE
    - cs.DL
    - cs.IR
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
compares it with related approaches [@cagle2026databooks; @ozekik2023markdownld; @davay422026mdld; @iunera2025jsonldmarkdown], and describes the `wiki` reference implementation.
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

## Zero Custom Syntax

LMD introduces no nonstandard Markdown syntax. All protocol semantics are
expressed through:

- Standard JSON-LD 1.1 frontmatter delimited by `---`
- Standard CommonMark links for document-level relationships
- Convention-based file organization (shapes, axioms, corpus structure)

A minimal LMD document is:

```yaml
---
id: https://example.org/docs/my-item
@type: schema:Article
@context:
  schema: https://schema.org/
---

# My Item
Content here.
```

This file is valid Markdown, valid YAML, and valid JSON-LD simultaneously.

## Document Model

Every LMD document is identified by a canonical IRI (`@id`) and
one or more RDF types (`@type`). The bare `id` and `type` aliases
are also valid in YAML frontmatter. Frontmatter fields map directly
to RDF predicate-value pairs with the document's `id` as subject. The
Markdown body (everything after the frontmatter) is addressable as an RDF
literal, typically via `schema:articleBody`.

Documents form a **corpus**: a collection of LMD documents sharing a
configuration, a shapes directory (for SHACL validation), and optional
axioms (for OWL-RL inference).

## Linking

Intra-corpus links use standard Markdown link syntax `[text](target.md)`.
A processor resolves the target filename to the target document's `id` IRI.
External links (to IRIs outside the corpus) are preserved as typed RDF
object properties. Fragment identifiers (`#section-2`) may be typed as
`rdf:HTML` content.

## Validation and Inference

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

## Query and Publishing

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

# Implementation: The wiki CLI

The canonical reference implementation of LMD is the **wiki** command-line
tool (`github.com/wazootech/wiki`, package `wazootech-wiki`).

The wiki CLI implements:

- **LMD-Core**: Parsing LMD documents from a filesystem corpus, resolving
  `@id` and `@type`, producing an RDF 1.1 graph using `rdflib`.
- **LMD-Validation**: SHACL validation against shapes in a `shapes/`
  directory, using `pyshacl`.
- **LMD-Query**: SPARQL 1.1 query execution via `rdflib`-embedded
  SPARQL engine.
- **LMD-Publish**: Static HTML site generation with content negotiation.
- **Virtual Graph Derivation**: The filesystem directory structure is
  treated as a virtual RDF graph, deriving document identity from file
  paths relative to the corpus root.

The CLI is implemented in Python and distributed via PyPI. Key
architectural decisions include: zero required configuration beyond a
corpus root; automatic shape and axiom discovery from convention-based
directories; and strict separation of parsing, validation, query, and
publish into independently invocable subcommands.

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

## Adoption Path

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

<!-- Full spec content below -->
<!-- TODO: insert spec/index.md content verbatim -->

---

*Repository: github.com/wazootech/linked-markdown-paper*
*Specification: github.com/wazootech/linked-markdown*
*Reference Implementation: github.com/wazootech/wiki*
