# 改訂（Reviewer 3）：検出力が監視年数 T に対して単調に増えるか（二分探索の前提）を密な格子で確認する。方法 a、努力量一定、φ = 0.69
source("sim/explore_common.R")
e <- const_eff(); d <- -log(0.7) / 10
jobs <- expand_grid(lambda0 = c(0.3, 1, 10, 100), T = seq(3, 100, by = 1))
pw <- parallel::mclapply(seq_len(nrow(jobs)), \(i) power_at(jobs$T[i], jobs$lambda0[i], e$E_flat, e$G, d, 0.69, 400, 20261103 + jobs$T[i])[["a"]], mc.cores = 12)
jobs$power <- unlist(pw)
mono <- jobs |> group_by(lambda0) |> arrange(T, .by_group = TRUE) |>
  summarise(max_drop = max(cummax(power) - power), first_T_power_0.8 = suppressWarnings(min(T[power >= 0.8])), .groups = "drop")
print(mono); readr::write_csv(jobs, "sim/rev_monotonicity.csv"); readr::write_csv(mono, "sim/rev_monotonicity_summary.csv")
