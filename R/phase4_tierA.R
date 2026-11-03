# Phase 4: Tier A（PREREG v1.0 §4）。brms + cmdstanr、Poisson-lognormal、ln N の誤差は me()、係数は 1 に固定

tierA_data <- function(sp, gy, years = 2000:2024, subset = c("report", "all")) {
  subset <- match.arg(subset)
  if (subset == "report") sp <- dplyr::filter(sp, report_based)
  R <- gy |> dplyr::filter(year %in% years, rtype != "fossil") |> dplyr::group_by(species) |>
    dplyr::summarise(R = sum(as.numeric(n)), .groups = "drop")
  sp |> dplyr::filter(!is.na(gbif_name), !is.na(M_g), !is.na(N), N > 0) |>
    dplyr::group_by(gbif_name) |>   # lump は合算（PREREG §4）
    dplyr::summarise(order = dplyr::first(order), M_g = sum(N * M_g) / sum(N), N = sum(N), N_lo = sum(N_lo), N_hi = sum(N_hi),
                     n_census_species = dplyr::n(), .groups = "drop") |>
    dplyr::left_join(R, by = c("gbif_name" = "species")) |>
    dplyr::mutate(R = as.integer(dplyr::coalesce(R, 0)), lnN = log(N),
                  # 下限が 0 の種（鳥類の一部）は上側の半幅から sd を作る
                  sdN = dplyr::if_else(N_lo > 0, (log(N_hi) - log(N_lo)) / (2 * 1.96), (log(N_hi) - log(N)) / 1.96),
                  sdN = pmax(sdN, 0.01), lnM = log(M_g), obs = dplyr::row_number())
}

fit_tierA <- function(d, seed = 20261103) {
  d <- dplyr::mutate(d, order = dplyr::coalesce(order, "unknown"))
  ords <- sort(unique(d$order))
  sd <- list(S = nrow(d), R = d$R, lnN_obs = d$lnN, sdN = d$sdN, lnM = d$lnM, O = length(ords),
             ord = match(d$order, ords), lnM_c = mean(d$lnM))
  stopifnot(all(is.finite(sd$sdN)), all(is.finite(sd$lnN_obs)))
  m <- cmdstanr::cmdstan_model("models/tierA_pln.stan")
  a0 <- mean(log(d$R + 0.5) - d$lnN)   # 初期値：切片は経験的な平均 ln r の近く
  init <- function() list(alpha = a0, beta = 0, sd_order = 0.5, tau = 1, z_order = rep(0, length(ords)), eta = log(d$R + 0.5))
  run <- function(it) m$sample(sd, seed = seed, chains = 4, parallel_chains = 4, iter_warmup = 1000, iter_sampling = it,
                               adapt_delta = 0.95, refresh = 0, show_messages = FALSE, init = init)
  f <- run(1000); sm <- f$summary(c("alpha", "beta", "sd_order", "tau"))
  if (max(sm$rhat) >= 1.01 || min(sm$ess_bulk, sm$ess_tail) <= 400) { f <- run(4000); sm <- f$summary(c("alpha", "beta", "sd_order", "tau")) }
  dr <- posterior::as_draws_df(f$draws(c("beta", "sd_order", "tau")))
  dg <- f$diagnostic_summary(quiet = TRUE)
  tibble::tibble(n_species = nrow(d), n_zero = sum(d$R == 0), n_orders = length(ords),
                 beta_med = median(dr$beta), beta_lo = quantile(dr$beta, .025), beta_hi = quantile(dr$beta, .975),
                 sd_order = median(dr$sd_order), tau = median(dr$tau),
                 rhat_max = max(sm$rhat), ess_bulk_min = min(sm$ess_bulk), ess_tail_min = min(sm$ess_tail),
                 divergent = sum(dg$num_divergent), treedepth_hits = sum(dg$num_max_treedepth))
}
