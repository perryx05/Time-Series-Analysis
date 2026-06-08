#!/usr/bin/env bash
# Export eda_report.md -> eda_report.tex (repo root) -> eda_report.pdf
#
# This creates a readable intermediate LaTeX file you can inspect/edit.
#
# Usage (from repo root):
#   ./scripts/export_eda_report_latex_pdf.sh
#   ./scripts/export_eda_report_latex_pdf.sh path/to/out.pdf
#
# Requirements:
#   - pandoc (brew install pandoc)
#   - a TeX engine (BasicTeX/MacTeX): xelatex recommended

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
OUT_TEX="${OUT_TEX:-eda_report.tex}"
BUILD_DIR="${BUILD_DIR:-build}"

if [[ ! -f "$MD" ]]; then
  echo "Error: $MD not found (run this from the repository root)." >&2
  exit 1
fi

if ! command -v pandoc >/dev/null 2>&1; then
  echo "Error: pandoc is not installed." >&2
  echo "Install on macOS:  brew install pandoc" >&2
  exit 1
fi

if ! command -v xelatex >/dev/null 2>&1; then
  echo "Error: xelatex not found. Install BasicTeX/MacTeX, then restart your terminal." >&2
  echo "macOS default TeX bin path: /Library/TeX/texbin" >&2
  exit 1
fi

mkdir -p "$BUILD_DIR"

echo "Writing LaTeX: $OUT_TEX"
pandoc "$MD" -o "$OUT_TEX" --standalone \
  --resource-path=".:plots" \
  -V geometry:margin=1in \
  -H "$ROOT/scripts/pandoc_pdf_include.tex"

echo "Building PDF: $OUT_PDF"
xelatex -interaction=nonstopmode -halt-on-error -output-directory "$BUILD_DIR" "$OUT_TEX" >/dev/null
xelatex -interaction=nonstopmode -halt-on-error -output-directory "$BUILD_DIR" "$OUT_TEX" >/dev/null

PDF_TMP="${BUILD_DIR}/$(basename "${OUT_TEX%.tex}.pdf")"
if [[ ! -f "$PDF_TMP" ]]; then
  echo "Error: expected PDF not found at $PDF_TMP" >&2
  exit 1
fi

mv -f "$PDF_TMP" "$OUT_PDF"
echo "OK: wrote $OUT_PDF"

