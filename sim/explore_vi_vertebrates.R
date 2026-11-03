# 探索的（1）：観測記録と独立なセンサスを持つ脊椎動物の種を、Tier B の直線と比べる
# 集合：indep = vert_census.csv の independent（海生哺乳類＋大型陸生）、report = Greenspoon の報告ベースの陸生哺乳類
# r_s = R_s / N_s（R_s：GBIF 2000–2024、化石除く）。残差 = log10 r_s − Tier B 主モデルの外挿（事後ドロー）
source("sim/explore_common.R")
tar_load(c(tb_main, mam_gy, mam_sp))
vc <- readr::read_csv("docs/provenance_parts/vert_census.csv", show_col_types = FALSE) |>
  filter(class == "Mammalia", method_class %in% c("independent", "mixed", "unclear"), !is.na(N_est), N_est > 0, !is.na(mass_g)) |>
  # 改訂：ゾウの二重計上（2 種を合わせた行）と未確認のホッキョクグマを除く（Reviewers 2, 5）
  filter(!grepl("s\\.l\\.", species), !(species == "Ursus maritimus" & verified != "yes")) |>
  transmute(species, set = paste0("census_", method_class), N = N_est, M_g = mass_g, scope)
rep <- mam_sp |> filter(report_based, !is.na(M_g), !is.na(N), N > 0) |> transmute(species, set = "report_land", N, M_g, scope = "global (IUCN/report)")
sp <- bind_rows(vc, rep)
sp <- add_gbif_name(sp, mam_gy)
R <- mam_gy |> filter(year %in% 2000:2024, rtype != "fossil") |> group_by(species) |> summarise(R = sum(n), .groups = "drop")
sp <- sp |> left_join(R, by = c("gbif_name" = "species")) |> mutate(R = coalesce(R, 0)) |>
  filter(name_route != "unmatched") |>
  mutate(log10M = log10(M_g), log10r = log10((R + 0.5) / N))
# Tier B の事後ドローで外挿した予測
dr <- tb_main$draws; k <- match("all", tb_main$types); c0 <- tb_main$data$lnM_c
a <- dr[[sprintf("a[%d]", k)]]; b <- dr[[sprintf("b[%d]", k)]]
pred <- sapply(sp$log10M * log(10), \(x) a + b * (x - c0)) / log(10)        # ドロー × 種
opt <- (median(a) + 2/3 * (sp$log10M * log(10) - c0)) / log(10)              # 傾き 2/3 の参照線
sp$resid_med <- sp$log10r - apply(pred, 2, median)
sp$resid_opt <- sp$log10r - opt
summ <- sp |> group_by(set) |> summarise(n = n(), n_zeroR = sum(R == 0), log10M_range = paste(round(range(log10M), 1), collapse = "–"),
                                         resid_vs_TierB_med = median(resid_med), resid_vs_TierB_q25 = quantile(resid_med, .25),
                                         resid_vs_TierB_q75 = quantile(resid_med, .75), resid_vs_opt_med = median(resid_opt),
                                         slope_within = coef(lm(log10r ~ log10M))[2], .groups = "drop")
# 予測の不確実性：各ドローでの集合ごと残差の中央値の分布
unc <- purrr::map(unique(sp$set), function(s) {
  i <- sp$set == s; m <- apply(sp$log10r[i] - t(pred[, i, drop = FALSE]), 2, median)
  tibble(set = s, resid_draw_med = median(m), resid_draw_lo = quantile(m, .025), resid_draw_hi = quantile(m, .975))
}) |> purrr::list_rbind()
summ <- left_join(summ, unc, by = "set")
print(summ, width = 200)
readr::write_csv(sp, "sim/explore_vertebrates_species.csv"); readr::write_csv(summ, "sim/explore_vertebrates_summary.csv")
