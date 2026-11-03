# 探索的解析（PREREG 外）の共通設定
suppressPackageStartupMessages({ library(targets); library(dplyr); library(tidyr) })
for (f in list.files("R", full.names = TRUE)) source(f)
Sys.setenv(OMP_NUM_THREADS = 1, OPENBLAS_NUM_THREADS = 1)
# 努力量一定（E_t = 1）の前向きシナリオ：「今年の λ から監視を始めたら何年で検出できるか」
const_eff <- function(horizon = 100, G = 1e5) tibble(group_id = "const", t = seq_len(horizon), G = G, E_flat = 1, E_grow = 1, growth = 0)
