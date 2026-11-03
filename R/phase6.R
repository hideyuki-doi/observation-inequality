# Phase 6：H5（未記載種）— 観測過程から「一度も記録されない種の割合」を予測し、文献の未記載割合と比べる（探索的）
# P(種 s が期間 T に一度も記録されない) = exp(−r N_s T/25)（r は 2000–2024 の 25 年あたりの記録数/個体）
# N_s ~ 対数正規（log10 SD = sigma10、平均 N_g / S_total）。r̂ と N_g は Tier B 主モデルの事後ドロー

richness_targets <- function(file = "docs/richness_selection.csv") {
  readr::read_csv(file, show_col_types = FALSE) |>
    dplyr::mutate(S_total = dplyr::coalesce(S_total_point, sqrt(S_total_lo * S_total_hi)))
}

h5_predict <- function(res, rich, S_desc, rec_species, sigma10 = 1.5, Tyears = c(25, 250), n_draw = 500, seed = 20261103) {
  set.seed(seed)
  dr <- res$draws[sample(nrow(res$draws), n_draw), ]
  k <- match("all", res$types); c0 <- res$data$lnM_c
  sig <- sigma10 * log(10); q <- qnorm((seq_len(400) - 0.5) / 400)   # SAD の分位点で期待値を数値積分
  purrr::map(intersect(res$labels, rich$group_id), function(g) {
    gi <- match(g, res$labels); rr <- dplyr::filter(rich, group_id == g)
    lnN <- dr[[sprintf("lnN[%d]", gi)]]; lnM <- dr[[sprintf("lnM[%d]", gi)]]
    lnr <- dr[[sprintf("a[%d]", k)]] + dr[[sprintf("b[%d]", k)]] * (lnM - c0)
    purrr::map(Tyears, function(Ty) {
      p0 <- vapply(seq_len(n_draw), function(j) {
        lnNs <- lnN[j] - log(rr$S_total) - sig^2 / 2 + sig * q
        mean(exp(-exp(lnr[j] + lnNs) * Ty / 25))
      }, 0)
      tibble::tibble(group_id = g, T_years = Ty, sigma10 = sigma10, log10M = median(lnM) / log(10),
                     S_total = rr$S_total, S_described = S_desc[[g]], recorded_2000_2024 = rec_species[[g]],
                     lit_undescribed_frac = 1 - S_desc[[g]] / rr$S_total,
                     obs_unrecorded_frac_of_total = 1 - rec_species[[g]] / rr$S_total,
                     pred_never_recorded_med = median(p0), pred_lo = quantile(p0, .025), pred_hi = quantile(p0, .975))
    }) |> purrr::list_rbind()
  }) |> purrr::list_rbind()
}

recorded_species_counts <- function(group_recs, tb_groups, years = 2000:2024) {
  x <- group_recs |> dplyr::semi_join(tb_groups, by = c("group_id", "variant")) |>
    dplyr::filter(!is.na(specieskey), specieskey != "", year %in% years, rtype != "fossil") |>
    dplyr::distinct(group_id, specieskey) |> dplyr::count(group_id)
  setNames(x$n, x$group_id)
}

fig_h5 <- function(h5, out = "figs/phase6_h5_unrecorded.pdf") {
  d <- dplyr::filter(h5, sigma10 == 1.5)
  p <- ggplot2::ggplot(d, ggplot2::aes(log10M)) +
    ggplot2::geom_pointrange(ggplot2::aes(y = pred_never_recorded_med, ymin = pred_lo, ymax = pred_hi, colour = factor(T_years)),
                             position = ggplot2::position_dodge(width = 0.3), size = 0.25) +
    ggplot2::geom_point(ggplot2::aes(y = lit_undescribed_frac), shape = 4, size = 2.5) +
    ggplot2::geom_point(ggplot2::aes(y = obs_unrecorded_frac_of_total), shape = 2, size = 2) +
    ggplot2::geom_text(ggplot2::aes(y = lit_undescribed_frac, label = group_id), size = 2.3, vjust = -1) +
    ggplot2::scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
    ggplot2::labs(x = "log10 body mass M (g wet)", y = "share of all species (described + undescribed)", colour = "predicted: window (yr)",
                  caption = "EXPLORATORY. Points+bars: predicted share never recorded (observation model, SAD σ10 = 1.5).\n×: literature undescribed share (1 − described/estimated total). △: observed share not recorded in GBIF 2000–2024.") +
    ggplot2::theme_bw(9)
  ggplot2::ggsave(out, p, width = 7.5, height = 5, device = grDevices::cairo_pdf); out
}
