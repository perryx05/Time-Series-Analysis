#!/usr/bin/env bash
# Export final_report_revised.md to PDF (Pandoc -> LaTeX -> xelatex/pdflatex/lualatex).
# Strips the internal "author note" section (marked REMOVE BEFORE SUBMISSION).
# Figures live in figures/. Usage (from repo root):
#   ./scripts/export_final_report_pdf.sh [out.pdf]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
# MacTeX/BasicTeX is often not on PATH for non-login shells.
if [[ -d "/Library/TeX/texbin" ]]; then export PATH="/Library/TeX/texbin:${PATH}"; fi

MD="${MD:-final_report_revised.md}"
OUT_PDF="${1:-final_report_revised.pdf}"
BUILD_DIR="build"; mkdir -p "$BUILD_DIR"
CLEAN_MD="${BUILD_DIR}/final_report_clean.md"
TEX_OUT="${BUILD_DIR}/final_report.tex"

command -v pandoc >/dev/null 2>&1 || { echo "Error: pandoc not installed." >&2; exit 1; }

# --- drop the internal author note (from the REMOVE-BEFORE-SUBMISSION marker) ---
LN="$(grep -n "REMOVE BEFORE SUBMISSION" "$MD" | head -1 | cut -d: -f1 || true)"
if [[ -n "${LN:-}" ]]; then
  head -n "$((LN - 4))" "$MD" > "$CLEAN_MD"   # also trims the preceding '---' + blank + comment line
else
  cp "$MD" "$CLEAN_MD"
fi

# --- markdown -> standalone LaTeX (engine-agnostic via iftex in pandoc's template) ---
pandoc "$CLEAN_MD" -o "$TEX_OUT" --standalone \
  --resource-path=".:figures" \
  -V geometry:margin=1in -V fontsize=11pt \
  -V colorlinks=true -V linkcolor=RoyalBlue -V urlcolor=RoyalBlue \
  -H "$ROOT/scripts/pandoc_pdf_include.tex" \
  -H "$ROOT/scripts/pandoc_unicode.tex"

# --- compile (twice, so any references settle); try engines in order ---
for engine in xelatex pdflatex lualatex; do
  command -v "$engine" >/dev/null 2>&1 || continue
  if "$engine" -interaction=nonstopmode -halt-on-error -output-directory "$BUILD_DIR" "$TEX_OUT" >"${BUILD_DIR}/tex_${engine}.log" 2>&1 \
     && "$engine" -interaction=nonstopmode -halt-on-error -output-directory "$BUILD_DIR" "$TEX_OUT" >"${BUILD_DIR}/tex_${engine}.log" 2>&1; then
    mv -f "${BUILD_DIR}/final_report.pdf" "$OUT_PDF"
    echo "OK: wrote $OUT_PDF (engine: $engine)"
    exit 0
  fi
  echo "engine $engine failed (see ${BUILD_DIR}/tex_${engine}.log)" >&2
done

echo "PDF build failed with all LaTeX engines." >&2
exit 1
