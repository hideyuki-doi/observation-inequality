# (3) 探索的：無脊椎動物グループ自身の φ（記録の多さの層ごと）で、努力量一定の T_detect 格子をやり直す
source("sim/explore_common.R")
ph <- readr::read_csv("sim/explore_phi_inverts.csv", show_col_types = FALSE)
phi_m <- readr::read_csv("sim/phi_estimate.csv", show_col_types = FALSE)$phi_med
phi_of <- function(g, lam) {
  if (!g %in% ph$group_id) return(phi_m)   # オキアミ（1種）は哺乳類の値
  s <- if (lam < 1) "<1" else if (lam < 10) "1-10" else ">=10"
  ph$theta[ph$group_id == g & ph$stratum == s]
}
groups <- c(unique(ph$group_id), "krill")
jobs <- expand_grid(group_id = groups, lambda0 = 10^seq(-2, 5, length.out = 36), decline = c("30%/10yr", "50%/10yr")) |>
  mutate(d = ifelse(decline == "30%/10yr", -log(0.7) / 10, -log(0.5) / 10))
e <- const_eff()
res <- parallel::mclapply(seq_len(nrow(jobs)), function(i) {
  p <- phi_of(jobs$group_id[i], jobs$lambda0[i])
  c(t_detect_all(jobs$lambda0[i], e$E_flat, e$G, jobs$d[i], p), phi = p)
}, mc.cores = 12, mc.preschedule = FALSE)
out <- bind_cols(jobs, bind_rows(lapply(res, as.list)))
readr::write_csv(out, "sim/explore_group_phi_grid.csv")
