# Phase 5：T_detect を体重 M に写す（PREREG v1.0 §5）
# 種の個体数は対数正規（log10 SD = sigma10）、種数 S_g、平均 N_g/S_g。λ_s0 = r̂(M_g) w_g N_s
# T_detect は λ0 に対して単調減少なので、「T 年以内に検出できる種の割合」= P(λ_s0 ≥ λ*_g(T)) を解析的に計算する

# 格子から λ*_g(T)：T 年以内に検出できる最小の λ0（log λ0 で線形補間）
lambda_star <- function(grid_g, Tcol, Ts) {
  g <- dplyr::arrange(grid_g, lambda0); x <- log(g$lambda0); y <- g[[Tcol]]
  vapply(Ts, function(T) {
    ok <- which(y <= T)
    if (!length(ok)) return(Inf)
    i <- min(ok); if (i == 1) return(x[1])
    x[i - 1] + (x[i] - x[i - 1]) * 0.5   # 隣の格子点の中間（格子幅 = 0.2 log10 単位）
  }, 0)
}

described_species <- function(census_main) {
  # census_main に記載種数がない主グループは harmonized.csv（Catalogue of Life 2026-10-14）の値を使う
  s <- setNames(suppressWarnings(as.numeric(census_main$n_described_species)), census_main$group_id)[census_main$role == "main"]
  add <- c(soil_nematodes = 19667, springtails = 8926, ants = 14438)   # harmonized.csv の行（Nematoda 全体、Collembola、Formicidae）
  s[is.na(s)] <- add[names(s)[is.na(s)]]
  s
}

map_tdetect <- function(res, grid, eff, S, sigma10 = 1.5, Tcol = "T_a", Ts = c(3:100), n_draw = 1000, seed = 20261103,
                        no_sad_single = FALSE) {   # 探索的 (ii)：種数 1 のグループでは SAD を外す
  set.seed(seed)
  dr <- res$draws[sample(nrow(res$draws), n_draw), ]
  k <- match("all", res$types); c0 <- res$data$lnM_c
  sig <- sigma10 * log(10)
  labs <- res$labels
  w <- eff |> dplyr::filter(t <= 25) |> dplyr::group_by(group_id) |> dplyr::summarise(w = E_flat[25] / sum(E_flat))
  lstar <- lapply(setNames(labs, labs), \(g) lambda_star(dplyr::filter(grid, group_id == g), Tcol, Ts))
  # 各ドローで、各グループの ln λ_s0 の対数正規パラメータ
  out <- purrr::map(seq_along(labs), function(gi) {
    g <- labs[gi]
    lnN <- dr[[sprintf("lnN[%d]", gi)]]; lnM <- dr[[sprintf("lnM[%d]", gi)]]
    lnr <- dr[[sprintf("a[%d]", k)]] + dr[[sprintf("b[%d]", k)]] * (lnM - c0)
    sg <- if (no_sad_single && S[[g]] == 1) 1e-6 else sig
    mu <- lnr + log(w$w[w$group_id == g]) + lnN - log(S[[g]]) - sg^2 / 2
    tibble::tibble(group_id = g, draw = seq_len(n_draw), lnM = lnM, mu = mu, S = S[[g]], sg = sg)
  }) |> purrr::list_rbind()
  # 検出できる割合 F_g(T) = P(ln λ ≥ ln λ*(T))
  Fg <- out |> dplyr::rowwise() |>
    dplyr::mutate(F = list(1 - pnorm((lstar[[group_id]] - mu) / sg))) |> dplyr::ungroup()
  list(Fg = Fg, Ts = Ts, sigma10 = sigma10, Tcol = Tcol)
}

# サイズ三分位（主 10 グループの観測 log M の範囲を等幅で3分割）ごとの、種の中央値 T_detect と H3 判定
h3_summary <- function(mp, lnM_obs) {
  br <- seq(min(lnM_obs), max(lnM_obs), length.out = 4)
  terc <- setNames(cut(lnM_obs, br, include.lowest = TRUE, labels = c("lower", "middle", "upper")), names(lnM_obs))
  Fg <- dplyr::mutate(mp$Fg, tercile = terc[group_id])
  per_draw <- Fg |> dplyr::group_by(draw, tercile) |>
    dplyr::summarise(Fpool = list(Reduce(`+`, purrr::map2(F, S, `*`)) / sum(S)), .groups = "drop") |>
    dplyr::mutate(T_med = purrr::map_dbl(Fpool, \(f) { i <- which(f >= 0.5); if (length(i)) mp$Ts[min(i)] else Inf }),
                  undetect_25 = purrr::map_dbl(Fpool, \(f) 1 - f[mp$Ts == 25]),
                  undetect_100 = purrr::map_dbl(Fpool, \(f) 1 - f[mp$Ts == 100]))
  ratio <- per_draw |> dplyr::select(draw, tercile, T_med) |> tidyr::pivot_wider(names_from = tercile, values_from = T_med) |>
    dplyr::mutate(ratio = lower / upper)   # 両方 Inf（どちらも過半数が検出不能）は NaN → 別に数える
  tab <- per_draw |> dplyr::group_by(tercile) |>
    dplyr::summarise(T_med_post = median(T_med), T_med_lo = quantile(T_med, .025), T_med_hi = quantile(T_med, .975),
                     undetect_25_med = median(undetect_25), undetect_25_lo = quantile(undetect_25, .025), undetect_25_hi = quantile(undetect_25, .975),
                     undetect_100_med = median(undetect_100), groups = paste(names(terc)[terc == dplyr::first(tercile)], collapse = ","), .groups = "drop")
  both_inf <- mean(is.nan(ratio$ratio))
  r_med <- median(ratio$ratio, na.rm = TRUE)
  lower_majority_undetectable <- median(per_draw$undetect_100[per_draw$tercile == "lower"]) > 0.5
  list(tercile = tab, ratio_med = r_med, ratio_lo = quantile(ratio$ratio, .025, na.rm = TRUE), ratio_hi = quantile(ratio$ratio, .975, na.rm = TRUE),
       share_draws_both_undetectable = both_inf,
       lower_majority_undetectable = lower_majority_undetectable,
       H3 = if (is.finite(r_med) && r_med >= 10 || lower_majority_undetectable || (is.infinite(r_med))) "size-structured detection delay" else "not supported",
       sigma10 = mp$sigma10, Tcol = mp$Tcol)
}

# グループ別：25 年以内に検出できない種の割合（事後中央値と 95% 区間）
group_undetect <- function(mp) {
  mp$Fg |> dplyr::mutate(u25 = purrr::map_dbl(F, \(f) 1 - f[mp$Ts == 25]), u100 = purrr::map_dbl(F, \(f) 1 - f[mp$Ts == 100])) |>
    dplyr::group_by(group_id) |>
    dplyr::summarise(log10M = median(lnM) / log(10), S = dplyr::first(S),
                     undetect25_med = median(u25), undetect25_lo = quantile(u25, .025), undetect25_hi = quantile(u25, .975),
                     undetect100_med = median(u100), .groups = "drop") |>
    dplyr::mutate(sigma10 = mp$sigma10, method = mp$Tcol)
}
