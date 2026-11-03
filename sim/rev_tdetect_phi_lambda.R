# 改訂：分類群ごと・記録の多さごとの φ（種ごとの線形傾向を除いた推定、sim/rev_phi_species_summary.csv）で、
# 努力量一定の T_detect 格子（方法 a、30%/10 年）を作り直す。λ < 10 は層 1–10、10–100、≥100 の値を使う
source("sim/explore_common.R")
ps <- readr::read_csv("sim/rev_phi_species_summary.csv", show_col_types = FALSE) |> filter(!is.na(phi_linear), n_species >= 10)
sets <- c("soil_nematodes", "mites", "copepods", "springtails", "enchytraeids", "pteropods", "ants", "jellyfish", "mesopelagic_fish",
          "mammals", "birds (eBird)", "birds (excluding eBird)")
phi_of <- function(s, lam) {
  x <- filter(ps, set == s); st <- if (lam < 10) "1-10" else if (lam < 100) "10-100" else ">=100"
  v <- x$phi_linear[x$stratum == st]; if (!length(v)) v <- x$phi_linear[nrow(x)]   # 層がなければ最上位の層
  v
}
jobs <- expand_grid(set = sets, lambda0 = 10^seq(-2, 4, length.out = 31)) |> rowwise() |> mutate(phi = phi_of(set, lambda0)) |> ungroup()
e <- const_eff()
res <- parallel::mclapply(seq_len(nrow(jobs)), \(i) t_detect_all(jobs$lambda0[i], e$E_flat, e$G, -log(0.7) / 10, jobs$phi[i], n_rep = 500),
                          mc.cores = 14, mc.preschedule = FALSE)
out <- bind_cols(jobs, bind_rows(lapply(res, as.list)))
readr::write_csv(out, "sim/rev_tdetect_phi_lambda.csv")
print(out |> group_by(set) |> summarise(floor = min(T_a), lambda_never = max(lambda0[is.infinite(T_a)])), n = 20)
