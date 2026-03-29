# Singapore births & fertility time series (1960–2024)

Reproducible time series exploration of Singapore:

- **Total Live Births (TLB)**: annual number of live births
- **Total Fertility Rate (TFR)**: annual fertility rate (children per woman; period measure)

The repo includes a clean dataset, a single R script that regenerates plots end-to-end, and a short write-up with interpretations.

## Quickstart

### Requirements

- **R**
- R package: **`tseries`** (for the ADF test)

Install once:

```r
install.packages("tseries")
```

### Run

From the repository root:

```bash
Rscript eda.R
```

This regenerates figures under `plots/` and prints diagnostics to the console.

## What’s in this repo

- **`eda.R`**: main script (load → clean → plots → ADF → preliminary AR/MA/ARMA on train period)
- **`eda_report.md`**: narrative + figure links
- **`M810091.csv`**: raw SingStat export (wide format)
- **`cleaned_tlb_tfr_1960_2024.csv`**: cleaned tidy dataset (`Year`, `TLB`, `TFR`)
- **`plots/`**: generated PNG outputs

## Data notes

- Annual data has **no within-year seasonality**.
- SingStat metadata: **TFR before 1980** refers to total population; **from 1980** refers to resident population. Long-run comparisons should keep this in mind.

## Export the write-up to PDF (optional)

If you want a PDF copy of `eda_report.md`, one straightforward approach is Pandoc:

```bash
pandoc eda_report.md -o eda_report.pdf --pdf-engine=xelatex
```

