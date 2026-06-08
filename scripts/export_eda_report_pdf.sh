#!/usr/bin/env bash
# Export eda_report.md to PDF when possible (Pandoc + LaTeX), or to standalone HTML
# for "Print to PDF" in a browser when LaTeX is not installed.
#
# Usage (from repo root):
#   ./scripts/export_eda_report_pdf.sh
#   ./scripts/export_eda_report_pdf.sh path/to/out.pdf

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# macOS TeX distributions (MacTeX/BasicTeX) commonly install here but
# the directory is not always on PATH for non-login shells.
if [[ -d "/Library/TeX/texbin" ]]; then
  export PATH="/Library/TeX/texbin:${PATH}"
fi

MD="${MD:-eda_report.md}"
OUT_PDF="${1:-eda_report.pdf}"
BUILD_DIR="${BUILD_DIR:-build}"
HTML_OUT="${BUILD_DIR}/eda_report_print.html"

if [[ ! -f "$MD" ]]; then
  echo "Error: $MD not found (run this from the repository root)." >&2
  exit 1
fi

if ! command -v pandoc >/dev/null 2>&1; then
  echo "Error: pandoc is not installed." >&2
  echo "Install on macOS:  brew install pandoc" >&2
  exit 1
fi

try_pdf() {
  local engine="$1"
  mkdir -p "$BUILD_DIR"
  local tex_out="${BUILD_DIR}/eda_report_pandoc.tex"
  local pdf_tmp="${BUILD_DIR}/eda_report_pandoc.pdf"

  # Pandoc spawning TeX engines can fail in some sandboxed environments.
  # Instead: generate LaTeX, then run the engine directly.
  pandoc "$MD" -o "$tex_out" --standalone \
    --resource-path=".:plots" \
    -V geometry:margin=1in \
    -H "$ROOT/scripts/pandoc_pdf_include.tex"

  "$engine" -interaction=nonstopmode -halt-on-error -output-directory "$BUILD_DIR" "$tex_out" >/dev/null
  "$engine" -interaction=nonstopmode -halt-on-error -output-directory "$BUILD_DIR" "$tex_out" >/dev/null

  if [[ -f "$pdf_tmp" ]]; then
    mv -f "$pdf_tmp" "$OUT_PDF"
    return 0
  fi

  return 1
}

echo "Trying to build PDF: $OUT_PDF"
for engine in xelatex pdflatex lualatex; do
  if command -v "$engine" >/dev/null 2>&1; then
    if try_pdf "$engine"; then
      echo "OK: wrote $OUT_PDF (engine: $engine)"
      exit 0
    fi
  fi
done

echo "No working LaTeX engine found (need MacTeX/BasicTeX or similar for PDF via Pandoc)."
echo "Falling back to standalone HTML (open in browser → Print → Save as PDF)."
mkdir -p "$BUILD_DIR"
pandoc "$MD" -o "$HTML_OUT" --standalone --embed-resources --mathjax \
  --resource-path=".:plots"

echo "OK: wrote $HTML_OUT"
echo "Next: open that file in Chrome/Safari → File → Print → Save as PDF"
exit 0
