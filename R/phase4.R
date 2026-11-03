# Phase 4: スケーリングの推定（PREREG v1.0 §1–3, §6–7）

# ---- 記録数の表：グループ × 記録の種類 ----
# rec: group_recs（gbif_taxon_year をグループに割り当てた表）
# years: 集計年（NULL = 全期間、年不明も含む）。weight: "n" / "ic"（individualCount 重み）/ "species"（種同定のみ）
R_table <- function(rec, groups, years = 2000:2024, weight = "n", ds_filter = NULL, dna_strict = FALSE) {
  x <- rec |> dplyr::filter(paste(group_id, variant) %in% paste(groups$group_id, groups$variant), rtype != "fossil")
  if (!is.null(years)) x <- dplyr::filter(x, year %in% years)
  if (!is.null(ds_filter)) x <- ds_filter(x)
  if (dna_strict) x <- dplyr::mutate(x, rtype = dplyr::if_else(rtype == "dna" & basisofrecord != "MATERIAL_SAMPLE", "other", rtype))
  x <- dplyr::mutate(x, w = switch(weight, n = n, ic = sum_ic + (n - n_ic),
                                   species = dplyr::if_else(!is.na(specieskey) & specieskey != "", n, 0L)))
  x <- dplyr::left_join(x, dplyr::select(groups, group_id, variant, label), by = c("group_id", "variant"))
  all <- x |> dplyr::group_by(label) |> dplyr::summarise(all = sum(as.numeric(w)), .groups = "drop")
  by <- x |> dplyr::filter(rtype %in% c("human_obs", "specimen", "dna")) |> dplyr::group_by(label, rtype) |>
    dplyr::summarise(R = sum(as.numeric(w)), .groups = "drop") |> tidyr::pivot_wider(names_from = rtype, values_from = R, values_fill = 0)
  out <- dplyr::left_join(all, by, by = "label")
  for (k in c("human_obs", "specimen", "dna")) if (!k %in% names(out)) out[[k]] <- 0
  dplyr::mutate(out, dplyr::across(c(human_obs, specimen, dna), \(v) dplyr::coalesce(v, 0)))
}

# ---- センサスの観測と誤差（PREREG §2） ----
sd_ci <- function(lo, hi, z = 1.96) (log(hi) - log(lo)) / (2 * z)
census_obs <- function(cm, fold_none = 10, fold_m = 3, extra_B_factor = NULL) {
  sd_default <- log(fold_none) / 1.96
  cm <- dplyr::mutate(cm, label = group_id)
  if (!is.null(extra_B_factor)) cm <- dplyr::mutate(cm, B_g_wet = B_g_wet * dplyr::coalesce(extra_B_factor[group_id], 1))
  sdN <- dplyr::case_when(cm$N_interval_type == "range" ~ sd_ci(cm$N_lo, cm$N_hi),
                          cm$N_interval_type == "未確認" ~ pmax(sd_ci(cm$N_lo, cm$N_hi), sd_default),  # ± の意味不明 → 既定値と大きい方
                          TRUE ~ sd_default)
  sdB <- dplyr::case_when(cm$B_interval_type == "range" ~ sd_ci(cm$B_lo_g_wet, cm$B_hi_g_wet),
                          cm$B_interval_type == "fold_uncertainty" ~ log(cm$B_g_wet / cm$B_lo_g_wet) / 1.96,
                          cm$B_interval_type == "CI95" ~ sd_ci(cm$B_lo_g_wet, cm$B_hi_g_wet),
                          TRUE ~ sd_default)
  sdN[is.na(sdN)] <- sd_default; sdB[is.na(sdB)] <- sd_default
  baron <- cm$part == "harmonized" & cm$group_id %in% c("copepods", "enchytraeids", "pteropods", "jellyfish", "mesopelagic_fish", "soil_nematodes")
  dplyr::bind_rows(
    tibble::tibble(label = cm$label, type = ifelse(baron, 3L, 1L),
                   val = ifelse(baron, log(cm$B_g_wet / cm$N), log(cm$N)),
                   sd = ifelse(baron, log(fold_m) / 1.96, sdN)),
    tibble::tibble(label = cm$label, type = 2L, val = log(cm$B_g_wet), sd = sdB))
}

# ---- Stan 当てはめ ----
fit_tierB <- function(obs, Rt, types = c("all", "human_obs", "specimen", "dna"), seed = 20261103,
                      model = "models/tierB_eiv.stan", tau_sd = 2, iter = 1000) {
  labs <- sort(unique(obs$label))
  Rt <- Rt[match(labs, Rt$label), ]
  stopifnot(!anyNA(Rt$label))
  # R = 0 の種類は除外（PREREG §6-2）：種類ごとに別モデルにせず、0 を含む種類は K から外して報告
  keep <- types[vapply(types, \(k) all(Rt[[k]] > 0), TRUE)]
  dropped <- setdiff(types, keep)
  lnM_obs <- vapply(labs, \(l) { o <- obs[obs$label == l, ]; if (any(o$type == 3)) o$val[o$type == 3] else o$val[o$type == 2] - o$val[o$type == 1] }, 0)
  d <- list(G = length(labs), K = length(keep), J = nrow(obs), obs_g = match(obs$label, labs), obs_type = obs$type,
            obs_val = obs$val, obs_sd = obs$sd, R = as.matrix(Rt[keep]), lnM_c = mean(lnM_obs),
            prior_lnN_mu = 40, prior_lnM_mu = -8)
  src <- readLines(model); src <- sub("tau ~ normal(0, 2);", sprintf("tau ~ normal(0, %s);", tau_sd), src, fixed = TRUE)
  m <- cmdstanr::cmdstan_model(cmdstanr::write_stan_file(src))
  run <- function(it) m$sample(d, seed = seed, chains = 4, parallel_chains = 4, iter_warmup = 1000, iter_sampling = it,
                               adapt_delta = 0.99, refresh = 0, show_messages = FALSE)
  f <- run(iter); sm <- f$summary()
  # PREREG §3：R-hat ≥ 1.01 または ESS ≤ 400 なら sampling を 4000 に増やす
  if (max(sm$rhat, na.rm = TRUE) >= 1.01 || min(sm$ess_bulk, sm$ess_tail, na.rm = TRUE) <= 400) { f <- run(4000); sm <- f$summary() }
  # CmdStan の CSV は一時ファイルなので、draws と診断を結果に持たせる
  list(draws = posterior::as_draws_df(f$draws()), summary = sm, diag = f$diagnostic_summary(quiet = TRUE),
       data = d, labels = labs, types = keep, dropped = dropped, lnM_obs = lnM_obs, Rt = Rt)
}

# 収束診断と判定（PREREG §3）
summarise_tierB <- function(res, name) {
  dr <- res$draws; dg <- res$diag; sm <- res$summary
  ndraw <- nrow(dr)
  out <- purrr::map(seq_along(res$types), function(k) {
    b <- dr[[sprintf("b[%d]", k)]]; r2 <- dr[[sprintf("R2[%d]", k)]]
    tibble::tibble(analysis = name, type = res$types[k], G = res$data$G,
                   beta_med = median(b), beta_lo = quantile(b, .025), beta_hi = quantile(b, .975),
                   beta_width = beta_hi - beta_lo, R2_med = median(r2),
                   tau_med = median(dr[[sprintf("tau[%d]", k)]]),
                   P_gt_opt = mean(b - 2/3 > 0.2), P_lt_opt = mean(b - 2/3 < -0.2))
  }) |> purrr::list_rbind()
  out |> dplyr::mutate(
    H1 = dplyr::case_when(beta_width < 0.3 & R2_med > 0.7 ~ "clean scaling",
                          beta_width < 0.6 & R2_med > 0.7 ~ "scaling (limited precision)",
                          TRUE ~ "not confirmed"),
    H2 = dplyr::case_when(P_gt_opt > 0.95 ~ "human interest dominant", P_lt_opt > 0.95 ~ "flatter than optical",
                          TRUE ~ "indistinguishable from optical"),
    rhat_max = max(sm$rhat, na.rm = TRUE), ess_bulk_min = min(sm$ess_bulk, na.rm = TRUE),
    ess_tail_min = min(sm$ess_tail, na.rm = TRUE),
    divergent_frac = sum(dg$num_divergent) / ndraw, dropped_types = paste(res$dropped, collapse = ";"))
}

# H4：P(b_dna < b_human_obs)
h4_test <- function(res, name) {
  if (!all(c("dna", "human_obs") %in% res$types)) return(tibble::tibble(analysis = name, P_dna_lt_human = NA_real_))
  dr <- res$draws
  bd <- dr[[sprintf("b[%d]", match("dna", res$types))]]; bh <- dr[[sprintf("b[%d]", match("human_obs", res$types))]]
  p <- mean(bd < bh)
  tibble::tibble(analysis = name, P_dna_lt_human = p, diff_med = median(bd - bh),
                 H4 = dplyr::case_when(p > 0.9 ~ "supported", p < 0.1 ~ "opposite direction", TRUE ~ "inconclusive"))
}

# グループごとの潜在値と残差（図用）
tierB_points <- function(res, name) {
  dr <- res$draws
  purrr::map(seq_along(res$labels), function(g) {
    lnN <- dr[[sprintf("lnN[%d]", g)]]; lnM <- dr[[sprintf("lnM[%d]", g)]]
    purrr::map(seq_along(res$types), function(k) {
      lnr <- log(res$data$R[g, k]) - lnN
      fit <- dr[[sprintf("a[%d]", k)]] + dr[[sprintf("b[%d]", k)]] * (lnM - res$data$lnM_c)
      tibble::tibble(analysis = name, label = res$labels[g], type = res$types[k], R = res$data$R[g, k],
                     log10M_med = median(lnM) / log(10), log10M_lo = quantile(lnM, .025) / log(10), log10M_hi = quantile(lnM, .975) / log(10),
                     log10r_med = median(lnr) / log(10), log10r_lo = quantile(lnr, .025) / log(10), log10r_hi = quantile(lnr, .975) / log(10),
                     resid_med = median(lnr - fit) / log(10))
    }) |> purrr::list_rbind()
  }) |> purrr::list_rbind()
}

# ---- 感度分析（PREREG §7）：名前ごとに obs と R を作る ----
sens_names <- c("S1_cumulative", "S2_S9_no_ebird", "S3_individualcount", "S4_species_level",
                "S5a_nematodes_baron", "S5c_ants_schultheiss", "S6a_acari_all", "S6b_plus_hydrozoa",
                "S7a_fold5", "S7b_fold20", "S7c_mfold10", "S8a_plankton_Cx10", "S9_add_birds_mammals",
                paste0("S10_drop_", c("soil_nematodes", "springtails", "mites", "ants", "enchytraeids", "copepods",
                                       "pteropods", "jellyfish", "mesopelagic_fish", "krill")),
                "S11a_no_inat", "S11b_inat_only", "S12_add_prokaryotes", "S14_dna_strict")

# S9 用：鳥類（Callaghan）と陸生哺乳類（Greenspoon 全種）をグループ点として作る（照合できた種の記録数）
tierA_group_rows <- function(mam_sp, bird_sp, mam_gy, bird_gy, years = 2000:2024, no_ebird = FALSE) {
  one <- function(sp, gy, label) {
    g <- gy |> dplyr::filter(species %in% sp$gbif_name, year %in% years, rtype != "fossil")
    if (no_ebird) g <- dplyr::filter(g, ds_class != "ebird")
    R <- tibble::tibble(label = label, all = sum(as.numeric(g$n)),
                        human_obs = sum(as.numeric(g$n[g$rtype == "human_obs"])),
                        specimen = sum(as.numeric(g$n[g$rtype == "specimen"])), dna = sum(as.numeric(g$n[g$rtype == "dna"])))
    s <- dplyr::filter(sp, !is.na(N), N > 0)
    N <- sum(s$N); B <- sum(s$N * s$M_g, na.rm = TRUE)   # 体重がない種は B から抜ける（数は報告）
    obs <- tibble::tibble(label = label, type = c(1L, 2L), val = log(c(N, B)),
                          sd = c(sd_ci(sum(s$N_lo), sum(s$N_hi)), log(10) / 1.96))
    list(R = R, obs = obs)
  }
  b <- one(bird_sp, bird_gy, "birds_callaghan"); m <- one(mam_sp, mam_gy, "mammals_greenspoon_all")
  list(R = dplyr::bind_rows(b$R, m$R), obs = dplyr::bind_rows(b$obs, m$obs))
}

sens_case <- function(name, census_main, group_recs, tb_groups, mam_sp, bird_sp, mam_gy, bird_gy) {
  cm <- dplyr::filter(census_main, role == "main"); g <- tb_groups
  obs_args <- list(); R_args <- list()
  swap <- function(cm, gid, role_new) dplyr::bind_rows(dplyr::filter(cm, group_id != gid),
                                                       dplyr::filter(census_main, group_id == gid, role == role_new))
  if (name == "S1_cumulative") R_args["years"] <- list(NULL)   # $<- NULL だと要素が消えて既定値に戻る
  if (name == "S3_individualcount") R_args$weight <- "ic"
  if (name == "S4_species_level") R_args$weight <- "species"
  if (name == "S5a_nematodes_baron") cm <- swap(cm, "soil_nematodes", "sens_baron")
  if (name == "S5c_ants_schultheiss") cm <- swap(cm, "ants", "sens_schultheiss")
  if (name == "S6a_acari_all") g$variant[g$group_id == "mites"] <- "acari_all"
  if (name == "S6b_plus_hydrozoa") g$variant[g$group_id == "jellyfish"] <- "plus_hydrozoa"
  if (name == "S7a_fold5") obs_args$fold_none <- 5
  if (name == "S7b_fold20") obs_args$fold_none <- 20
  if (name == "S7c_mfold10") obs_args$fold_m <- 10
  if (name == "S8a_plankton_Cx10") obs_args$extra_B_factor <- c(copepods = 1.5, pteropods = 1.5, jellyfish = 1.5)  # C×10 ÷ (C/0.15)
  if (startsWith(name, "S10_drop_")) { gid <- sub("S10_drop_", "", name); cm <- dplyr::filter(cm, group_id != gid); g <- dplyr::filter(g, group_id != gid) }
  if (name == "S11a_no_inat") R_args$ds_filter <- \(x) dplyr::filter(x, ds_class != "inat")
  if (name == "S11b_inat_only") R_args$ds_filter <- \(x) dplyr::filter(x, ds_class == "inat")
  if (name == "S14_dna_strict") R_args$dna_strict <- TRUE
  if (name == "S12_add_prokaryotes") {
    cm <- dplyr::bind_rows(cm, dplyr::filter(census_main, role == "dna_only"))
    g <- dplyr::bind_rows(g, tibble::tibble(group_id = c("bacteria", "archaea"), variant = "main", label = c("bacteria", "archaea")))
  }
  obs <- do.call(census_obs, c(list(cm), obs_args))
  R <- do.call(R_table, c(list(group_recs, g), R_args))
  if (name %in% c("S9_add_birds_mammals", "S2_S9_no_ebird")) {
    ta <- tierA_group_rows(mam_sp, bird_sp, mam_gy, bird_gy, no_ebird = name == "S2_S9_no_ebird")
    obs <- dplyr::bind_rows(obs, ta$obs); R <- dplyr::bind_rows(R, ta$R)
  }
  list(obs = obs, R = R)
}

run_sens <- function(name, ...) {
  inp <- sens_case(name, ...)
  res <- fit_tierB(inp$obs, inp$R)
  list(sum = summarise_tierB(res, name), h4 = h4_test(res, name), pts = tierB_points(res, name), R = dplyr::mutate(res$Rt, analysis = name))
}

# S13：モンテカルロ伝播 + 通常の回帰（errors-in-variables なし）
s13_mc_ols <- function(obs, Rt, n = 1000, seed = 20261103) {
  set.seed(seed)
  labs <- sort(unique(obs$label))
  purrr::map(c("all", "human_obs", "specimen", "dna"), function(k) {
    b <- replicate(n, {
      v <- obs$val + rnorm(nrow(obs), 0, obs$sd)
      lnN <- lnM <- setNames(numeric(length(labs)), labs)
      for (l in labs) { o <- obs$type[obs$label == l]; x <- v[obs$label == l]
        if (all(c(1, 2) %in% o)) { lnN[l] <- x[o == 1]; lnM[l] <- x[o == 2] - x[o == 1] }
        else { lnM[l] <- x[o == 3]; lnN[l] <- x[o == 2] - x[o == 3] } }
      R <- Rt[[k]][match(labs, Rt$label)]
      coef(lm(I(log(R) - lnN) ~ lnM))[2]
    })
    tibble::tibble(analysis = "S13_mc_ols", type = k, beta_med = median(b), beta_lo = quantile(b, .025), beta_hi = quantile(b, .975))
  }) |> purrr::list_rbind()
}
