# Phase 0: renv にパッケージを入れる（P3M バイナリ + stan-dev r-universe）
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/latest",
                  stan = "https://stan-dev.r-universe.dev"))
pk <- c("tidyverse", "rgbif", "posterior", "loo", "brms", "targets", "tarchetypes",
        "arrow", "httr2", "jsonlite", "yaml", "readxl", "data.table", "patchwork", "here")
for (p in pk) renv::install(p, prompt = FALSE)          # 段階的に（並列競合回避）
renv::install("cmdstanr", repos = c("https://stan-dev.r-universe.dev", getOption("repos")), prompt = FALSE)
renv::snapshot(prompt = FALSE)
