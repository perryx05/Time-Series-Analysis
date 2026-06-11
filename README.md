# Singapore births & fertility time series (1960–2024)

Reproducible time series exploration and forecasting of Singapore:

- **Total Live Births (TLB)**: annual number of live births
- **Total Fertility Rate (TFR)**: annual fertility rate (children per woman; period measure)

The repository includes a clean dataset, an end-to-end exploratory data analysis (EDA), and a full progression of time series modeling scripts that ultimately fit parsimonious SARIMA models leveraging the 12-year Chinese Zodiac cycle.

## Quickstart

### Requirements

- **R**
- R packages: **`forecast`**, **`tseries`**, **`ggplot2`**

Install dependencies once:

```r
install.packages(c("forecast", "tseries", "ggplot2"))
```

### Reproducing the Analysis

The modeling process is split into modular scripts. From the repository root, you can run them sequentially:

```bash
Rscript 01_stationarity_and_acf.R   # Stationarity tests and raw plots
Rscript 02_arima_candidates.R       # Baseline non-seasonal ARIMA evaluation
Rscript 03_sarima_candidates.R      # Baseline SARIMA evaluation
Rscript 04_high_p_models.R          # High-order ARIMA models (evaluating Zodiac lags)
Rscript 05_parsimony_models.R       # Final parsimonious SARIMA(4,1,0)(1,1,0)[12] fits
Rscript 06_final_models_figs.R      # Generate all figures used in the final report
```

Plots are saved out to the `plots/` directory.

## What’s in this repo

### Data
- **`M810091.csv`**: raw SingStat export (wide format)
- **`cleaned_tlb_tfr_1960_2024.csv`**: cleaned tidy dataset (`Year`, `TLB`, `TFR`)

### Code Pipeline
- **`eda.R`**: Initial exploratory data analysis.
- **`01_stationarity_and_acf.R`** to **`06_final_models_figs.R`**: The sequential modeling pipeline, exploring ARIMA, high-order polynomial fits, and ultimately parsimonious SARIMA models.
- **`scripts/`**: Additional helper and compilation scripts.
- **`plots/`**: Generated PNG outputs from both the EDA and the final modeling scripts.

### Reports
- **`eda_report.md` / `eda_report.pdf`**: The initial EDA narrative.
- **`identification_report.Rmd` / `.pdf`**: Investigation of the high-order models and the 12-year Zodiac cycle.
- **`final_report_revised.md` / `final_report_revised.pdf`**: The finalized time series project report, including residual diagnostics, model selection criteria, and out-of-sample forecasting on the 2013-2024 test window.

## Data notes

- Annual data has **no within-year seasonality**. The apparent "seasonality" discovered in the models is the strict 12-year recurrence of the Dragon and Tiger years in the Chinese Zodiac.
- SingStat metadata: **TFR before 1980** refers to total population; **from 1980** refers to resident population. Long-run comparisons should keep this in mind.

## Export the write-up to PDF (optional)

You can automatically compile the markdown reports to PDF using the provided shell scripts in the `scripts/` directory. For example:

```bash
chmod +x scripts/export_final_report_pdf.sh
./scripts/export_final_report_pdf.sh
```

You will need **Pandoc** (`brew install pandoc`) and a TeX distribution (e.g. MacTeX) to compile PDFs directly via the terminal.
