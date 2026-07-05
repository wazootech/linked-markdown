# LMD Paper

Build artifacts for *LMD: Linked Markdown — Markdown as Semantic Infrastructure*.

## Prerequisites

- [Pandoc](https://pandoc.org/installing.html) (≥ 3.x)
- A LaTeX distribution with `xelatex`:
  - **Windows:** [MiKTeX](https://miktex.org/download) (auto-installs missing packages on first build)
  - **macOS:** [MacTeX](https://tug.org/mactex/) or `brew install texlive`
  - **Linux:** `texlive-xetex` plus `texlive-latex-extra` (Ubuntu/Debian)

## Build

### Unix (Linux / macOS)

```sh
make
```

### Windows

```powershell
.\build.ps1
```

Or directly with Pandoc:

```sh
pandoc paper.md \
  --include-in-header=header.preamble \
  --bibliography=references.bib \
  --citeproc \
  --pdf-engine=xelatex \
  --toc \
  --number-sections \
  --no-highlight \
  -o paper.pdf
```

## Output

`paper.pdf` — a PDF with table of contents, numbered sections, and the full LMD specification as Appendix A.

## Files

| File | Purpose |
|------|---------|
| `paper.md` | Paper source (Markdown + YAML frontmatter with bibliography) |
| `header.preamble` | LaTeX preamble (margins, packages, listings style) |
| `references.bib` | BibTeX references |
| `Makefile` | Unix build automation |
| `build.ps1` | Windows PowerShell build script |
| `index.md` | Landing page for the paper directory |
