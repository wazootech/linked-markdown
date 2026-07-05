# Build the LMD paper PDF
# Requires: pandoc, xelatex (via MiKTeX or other LaTeX distribution)

$Source = "paper.md"
$Header = "header.preamble"
$Output = "paper.pdf"
$Bib = "references.bib"

$pandoc = Get-Command pandoc -ErrorAction SilentlyContinue
if (-not $pandoc) {
    Write-Error "pandoc not found. Install from https://pandoc.org/installing.html"
    exit 1
}

$xelatex = Get-Command xelatex -ErrorAction SilentlyContinue
if (-not $xelatex) {
    # Attempt to find MiKTeX in common install paths
    $miktexPaths = @(
        "$env:ProgramFiles\MiKTeX\miktex\bin\x64",
        "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64",
        "${env:ProgramFiles(x86)}\MiKTeX\miktex\bin\x64"
    )
    foreach ($p in $miktexPaths) {
        if (Test-Path "$p\xelatex.exe") {
            $env:Path = "$p;$env:Path"
            break
        }
    }
    $xelatex = Get-Command xelatex -ErrorAction SilentlyContinue
    if (-not $xelatex) {
        Write-Error "xelatex not found. Install MiKTeX from https://miktex.org/download"
        exit 1
    }
}

Write-Host "Building $Output ..."
& pandoc $Source `
    --include-in-header=$Header `
    --bibliography=$Bib `
    --citeproc `
    --pdf-engine=xelatex `
    --toc `
    --number-sections `
    --no-highlight `
    -o $Output

if ($?) {
    Write-Host "Done: $Output"
} else {
    Write-Error "Build failed"
    exit 1
}
