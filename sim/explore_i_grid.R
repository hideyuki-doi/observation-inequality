# (i)/(iv) 用：努力量一定での T_detect（30%/10 年 と 50%/10 年）
source("sim/explore_common.R")
phi <- readr::read_csv("sim/phi_estimate.csv", show_col_types = FALSE)$phi_med
g30 <- run_tdetect_grid(const_eff(), phi, d = -log(0.7) / 10) |> mutate(decline = "30%/10yr")
g50 <- run_tdetect_grid(const_eff(), phi, d = -log(0.5) / 10) |> mutate(decline = "50%/10yr")
readr::write_csv(bind_rows(g30, g50), "sim/explore_const_grid.csv")
