# Phase 5：検出の遅れのシミュレーション（PREREG v1.0 §5）

# ---- φ（負の二項の過分散）：報告ベースの哺乳類の種×年（2000–2024）----
# y_st ~ NegBin(μ, φ)、log μ = species_s + year_t（brms、固定効果、cmdstanr）
estimate_phi <- function(mam_sp, mam_gy, seed = 20261103) {
  sp <- unique(mam_sp$gbif_name[mam_sp$report_based & !is.na(mam_sp$gbif_name)])
  d <- mam_gy |> dplyr::filter(species %in% sp, year %in% 2000:2024, rtype != "fossil") |>
    dplyr::group_by(species, year) |> dplyr::summarise(y = sum(n), .groups = "drop") |>
    tidyr::complete(species = sp, year = 2000:2024, fill = list(y = 0)) |>
    dplyr::group_by(species) |> dplyr::filter(sum(y) > 0) |> dplyr::ungroup() |>
    dplyr::mutate(species = factor(species), year = factor(year))
  f <- brms::brm(y ~ 0 + species + year, data = d, family = brms::negbinomial(), backend = "cmdstanr",
                 prior = brms::prior(normal(0, 10), class = "b"),
                 chains = 4, cores = 4, iter = 2000, warmup = 1000, seed = seed, refresh = 0, silent = 2)
  sh <- posterior::as_draws_df(f, variable = "shape")$shape
  sm <- posterior::summarise_draws(posterior::as_draws_df(f, variable = "shape"))
  tibble::tibble(n_species = dplyr::n_distinct(d$species), n_obs = nrow(d),
                 phi_med = median(sh), phi_lo = quantile(sh, .025), phi_hi = quantile(sh, .975), rhat = sm$rhat, ess = sm$ess_bulk)
}

# ---- 努力量の軌跡 E_t（グループの GBIF 総記録数、2000 = 1）----
effort_paths <- function(rec_group_year, tb_groups, horizon = 100) {
  rec_group_year |> dplyr::semi_join(tb_groups, by = c("group_id", "variant")) |>
    dplyr::filter(year %in% 2000:2024, rtype != "fossil") |>
    dplyr::group_by(group_id, year) |> dplyr::summarise(G = sum(n), .groups = "drop") |>
    dplyr::group_by(group_id) |> dplyr::arrange(year, .by_group = TRUE) |>
    dplyr::group_modify(function(x, k) {
      E <- x$G / x$G[1]
      gr <- unname(coef(lm(log(E) ~ seq_along(E)))[2])      # 2000–2024 の対数線形の傾き
      t <- seq_len(horizon)
      tibble::tibble(t = t, G = c(x$G, rep(x$G[25], horizon - 25)),
                     E_flat = c(E, rep(E[25], horizon - 25)),            # 主：26 年目以降は 2024 年の水準
                     E_grow = c(E, E[25] * exp(gr * seq_len(horizon - 25))), # 感度：増加を外挿
                     growth = gr)
    }) |> dplyr::ungroup()
}

# ---- 1 系列の検定（片側、減少方向、α = 0.05）----
# a: NB-GLM + offset log E、b: 二項 GLM（試行数 = グループ総数 G）、c: NB-GLM オフセットなし
# 返り値：c(a, b, c) の「有意な減少」と、c の「有意な増加」
trend_tests <- function(y, E, G) {
  t <- seq_along(y); z <- qnorm(0.95)
  slope_z <- function(fit) { s <- summary(fit)$coefficients; if (nrow(s) < 2) NA_real_ else s[2, 1] / s[2, 2] }
  nb <- function(off) {
    if (sum(y) == 0) return(NA_real_)
    tryCatch(suppressWarnings(slope_z(if (is.null(off)) MASS::glm.nb(y ~ t) else MASS::glm.nb(y ~ t + offset(off)))),
             error = function(e) NA_real_)
  }
  za <- nb(log(E)); zc <- nb(NULL)
  # 相対報告率 = y / (y + 他種の記録数 O_t)。O_t はグループの実際の総記録数の軌跡（G）
  zb <- if (sum(y) == 0) NA_real_ else tryCatch(slope_z(suppressWarnings(glm(cbind(y, G) ~ t, family = binomial()))),
                                                error = function(e) NA_real_)
  # 当てはめ失敗（NA）は「検出なし」として数える（保守的）。失敗率は別に記録
  c(a = isTRUE(za < -z), b = isTRUE(zb < -z), c = isTRUE(zc < -z), c_up = isTRUE(zc > z),
    fail_a = is.na(za), fail_b = is.na(zb), fail_c = is.na(zc))
}

# 期待値 λ0 × E_t × exp(−d t)（t = 0 が初年）で n_rep 系列を作り、長さ T で検定した検出力
power_at <- function(T, lambda0, E, G, d, phi, n_rep, seed) {
  set.seed(seed)
  mu <- lambda0 * E[1:T] * exp(-d * (seq_len(T) - 1))
  res <- replicate(n_rep, trend_tests(rnbinom(T, size = phi, mu = mu), E[1:T], G[1:T]))
  rowMeans(res)
}

# 二分探索で検出力 ≥ 0.8 を初めて満たす T（3〜100）。満たさなければ Inf（検出不能）
# 検出力は T に対して単調に増えると仮定（PREREG 変更履歴に記載）。T ごとの検出力はキャッシュして3方法で共有
t_detect_all <- function(lambda0, E, G, d, phi, n_rep = 1000, seed = 20261103, Tmin = 3, Tmax = 100) {
  cache <- list()
  pw <- function(T) { k <- as.character(T); if (is.null(cache[[k]])) cache[[k]] <<- power_at(T, lambda0, E, G, d, phi, n_rep, seed + T); cache[[k]] }
  one <- function(m) {
    if (pw(Tmax)[[m]] < 0.8) return(Inf)
    if (pw(Tmin)[[m]] >= 0.8) return(Tmin)
    lo <- Tmin; hi <- Tmax
    while (hi - lo > 1) { mid <- (lo + hi) %/% 2; if (pw(mid)[[m]] >= 0.8) hi <- mid else lo <- mid }
    hi
  }
  out <- c(T_a = one("a"), T_b = one("b"), T_c = one("c"))
  fails <- colMeans(do.call(rbind, cache)[, c("fail_a", "fail_b", "fail_c"), drop = FALSE])   # 評価した全 T の平均失敗率
  c(out, fails)
}

# 全グループ × λ0 格子（PREREG：10^-2〜10^5 の対数等間隔 36 点）
run_tdetect_grid <- function(eff, phi, scenario_E = "E_flat", d = -log(0.7) / 10, n_rep = 1000, cores = 20,
                             lambda_grid = 10^seq(-2, 5, length.out = 36)) {
  jobs <- tidyr::expand_grid(group_id = unique(eff$group_id), lambda0 = lambda_grid)
  res <- parallel::mclapply(seq_len(nrow(jobs)), function(i) {
    e <- dplyr::filter(eff, group_id == jobs$group_id[i])
    t_detect_all(jobs$lambda0[i], e[[scenario_E]], e$G, d, phi, n_rep = n_rep)
  }, mc.cores = cores, mc.preschedule = FALSE)
  dplyr::bind_cols(jobs, dplyr::bind_rows(lapply(res, as.list))) |> dplyr::mutate(scenario = scenario_E, phi = phi)
}

# 対照シナリオ（d = 0）：T = 10, 25, 50 での偽の「減少」と、方法 c の偽の「増加」の割合
run_control <- function(eff, phi, n_rep = 1000, cores = 20, lambda_grid = 10^seq(-2, 5, length.out = 36), Ts = c(10, 25, 50)) {
  jobs <- tidyr::expand_grid(group_id = unique(eff$group_id), lambda0 = lambda_grid, T = Ts)
  res <- parallel::mclapply(seq_len(nrow(jobs)), function(i) {
    e <- dplyr::filter(eff, group_id == jobs$group_id[i])
    power_at(jobs$T[i], jobs$lambda0[i], e$E_flat, e$G, 0, phi, n_rep, 20261103 + jobs$T[i])
  }, mc.cores = cores, mc.preschedule = FALSE)
  dplyr::bind_cols(jobs, dplyr::bind_rows(lapply(res, as.list)))
}
