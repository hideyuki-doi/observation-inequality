# 改訂（Reviewers 1, 2, 5）：分類群の範囲を直した版で、記録数・種あたり記録率・自由係数モデルを確認する
source("sim/explore_common.R")
sv <- readr::read_csv("docs/taxon_scope_variants.csv", show_col_types = FALSE)
excl_mite <- sv$taxon[sv$group_id == "mites"]
excl_nem_ord <- sv$taxon[sv$group_id == "soil_nematodes" & grepl("order", sv$rule)]
excl_nem_fam <- sv$taxon[sv$group_id == "soil_nematodes" & grepl("family", sv$rule)]
meso15 <- sv$taxon[sv$rule == "include_family_mesopelagic15"]
d <- arrow::open_dataset("data/derived/gbif_taxon_year.parquet")
pull_grp <- function(expr, label) d |> filter({{ expr }}) |> filter(basisofrecord != "FOSSIL_SPECIMEN") |>
  group_by(specieskey, year) |> summarise(n = sum(n)) |> collect() |> ungroup() |> mutate(group_id = label)
v <- bind_rows(
  pull_grp(phylum == "Nematoda" & !(order %in% excl_nem_ord) & !(family %in% excl_nem_fam) & !is.na(order), "soil_nematodes"),
  pull_grp(order %in% c("Sarcoptiformes", "Mesostigmata", "Trombidiformes") & !(family %in% excl_mite), "mites"),
  pull_grp(family %in% meso15, "mesopelagic_fish"))
R_v <- v |> filter(year %in% 2000:2024) |> group_by(group_id) |> summarise(R_scope = sum(as.numeric(n)))
tar_load(c(tb_R, p5_S))
R_main <- tibble(group_id = tb_R$label, R_main = tb_R$all)
lam <- v |> filter(!is.na(specieskey), specieskey != "", year %in% 2015:2024) |> group_by(group_id, specieskey) |> summarise(lambda = sum(n) / 10, .groups = "drop")
S_main <- p5_S; S_alt <- c(soil_nematodes = 29000, mites = 55000)   # Hodda 2022b（Reviewer 5）
everrec <- v |> filter(!is.na(specieskey), specieskey != "") |> distinct(group_id, specieskey) |> count(group_id, name = "recorded_ever")
out <- lam |> group_by(group_id) |> summarise(recorded_2015_24 = n(), lam = list(lambda), .groups = "drop") |>
  left_join(everrec, by = "group_id") |>
  mutate(S_used = ifelse(group_id == "mesopelagic_fish", recorded_ever, S_main[group_id]),
         S_alt = ifelse(group_id %in% names(S_alt), S_alt[group_id], NA)) |> rowwise() |>
  mutate(share_zero = 1 - recorded_2015_24 / S_used, share_lt_0.32 = (sum(lam < 0.32) + S_used - recorded_2015_24) / S_used,
         share_lt_0.32_altS = ifelse(is.na(S_alt), NA, (sum(lam < 0.32) + S_alt - recorded_2015_24) / S_alt),
         share_lt_0.32_recorded = mean(lam < 0.32)) |> ungroup() |> select(-lam) |>
  left_join(R_v, by = "group_id") |> left_join(R_main, by = "group_id")
print(out, width = 200)
readr::write_csv(out, "sim/rev_scope_variants.csv")
# 自由係数モデル：記録数を範囲修正版に置き換えて当てはめ直す（記録数以外は主解析と同じ）
tar_load(tb_obs)
labs <- sort(unique(tb_obs$label)); R <- tb_R$all[match(labs, tb_R$label)]
R[match(out$group_id, labs)] <- out$R_scope
S <- p5_S[labs]; S["jellyfish"] <- 297
lnM_obs <- vapply(labs, \(l) { o <- tb_obs[tb_obs$label == l, ]; if (any(o$type == 3)) o$val[o$type == 3] else o$val[o$type == 2] - o$val[o$type == 1] }, 0)
lnN_obs <- vapply(labs, \(l) { o <- tb_obs[tb_obs$label == l, ]; if (any(o$type == 1)) o$val[o$type == 1] else o$val[o$type == 2] - o$val[o$type == 3] }, 0)
m <- cmdstanr::cmdstan_model("models/tierB_free.stan")
X <- matrix(log(S) - mean(log(S)), ncol = 1)
dd <- list(G = length(labs), J = nrow(tb_obs), P = 1, obs_g = match(tb_obs$label, labs), obs_type = tb_obs$type, obs_val = tb_obs$val, obs_sd = tb_obs$sd,
           R = R, X = X, cN = mean(lnN_obs), cM = mean(lnM_obs), prior_lnN_mu = 40, prior_lnM_mu = -8)
f <- m$sample(dd, seed = 20261103, chains = 4, parallel_chains = 4, iter_warmup = 1000, iter_sampling = 2000, adapt_delta = 0.99, refresh = 0, show_messages = FALSE)
dr <- posterior::as_draws_df(f$draws(c("gamma", "delta", "eta[1]")))
fr <- tibble(param = c("gamma (lnN)", "delta (lnM)", "lnS"), med = sapply(dr[1:3], median), lo = sapply(dr[1:3], quantile, .025), hi = sapply(dr[1:3], quantile, .975),
             P_gt0 = sapply(dr[1:3], \(v) mean(v > 0)))
print(fr); readr::write_csv(fr, "sim/rev_scope_free_exponent.csv")
