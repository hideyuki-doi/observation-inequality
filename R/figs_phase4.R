# Phase 4 の図
fig_tierB_scaling <- function(res, pts, out = "figs/phase4_tierB_scaling.pdf") {
  d <- dplyr::filter(pts, analysis == "main")
  # 主解析に入れないグループ（S9 の鳥類・哺乳類、S12 の原核生物）を白抜きで重ねる。値は各感度分析の潜在値
  ex <- dplyr::filter(pts, (analysis == "S9_add_birds_mammals" & label %in% c("birds_callaghan", "mammals_greenspoon_all")) |
                             (analysis == "S12_add_prokaryotes" & label %in% c("bacteria", "archaea")))
  dr <- res$draws; c0 <- res$data$lnM_c
  grid <- seq(min(c(d$log10M_lo, ex$log10M_med)) - 0.3, max(c(d$log10M_hi, ex$log10M_med)) + 0.3, length.out = 100)
  band <- purrr::map(seq_along(res$types), function(k) {
    a <- dr[[sprintf("a[%d]", k)]]; b <- dr[[sprintf("b[%d]", k)]]
    m <- sapply(grid * log(10), \(x) a + b * (x - c0)) / log(10)
    tibble::tibble(type = res$types[k], log10M = grid, med = apply(m, 2, median),
                   lo = apply(m, 2, quantile, .025), hi = apply(m, 2, quantile, .975),
                   opt = median(a) / log(10) + 2/3 * (grid - c0 / log(10)))   # 傾き 2/3 の参照線（中心を通す）
  }) |> purrr::list_rbind()
  sl <- summarise_tierB(res, "main") |> dplyr::transmute(type, lab = sprintf("β = %.2f [%.2f, %.2f]\nR² = %.2f", beta_med, beta_lo, beta_hi, R2_med))
  p <- ggplot2::ggplot(d, ggplot2::aes(log10M_med, log10r_med)) +
    ggplot2::geom_ribbon(data = band, ggplot2::aes(x = log10M, ymin = lo, ymax = hi), inherit.aes = FALSE, alpha = 0.2) +
    ggplot2::geom_line(data = band, ggplot2::aes(log10M, med), inherit.aes = FALSE) +
    ggplot2::geom_line(data = band, ggplot2::aes(log10M, opt), inherit.aes = FALSE, linetype = 2, colour = "grey40") +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = log10r_lo, ymax = log10r_hi), width = 0, colour = "grey50") +
    ggplot2::geom_errorbarh(ggplot2::aes(xmin = log10M_lo, xmax = log10M_hi), height = 0, colour = "grey50") +
    ggplot2::geom_point() + ggrepel_text(d) +
    ggplot2::geom_point(data = ex, shape = 1, colour = "firebrick") +
    ggplot2::geom_text(data = ex, ggplot2::aes(label = label), size = 2.3, vjust = -0.8, colour = "firebrick") +
    ggplot2::geom_text(data = sl, ggplot2::aes(x = -Inf, y = Inf, label = lab), hjust = -0.05, vjust = 1.1, size = 3, inherit.aes = FALSE) +
    ggplot2::facet_wrap(~type, scales = "free_y") +
    ggplot2::labs(x = "log10 body mass M (g wet)", y = "log10 records per individual r (2000–2024)",
                  caption = "black: main groups (fit = posterior median, 95% CrI); dashed: slope 2/3 through fitted centre;\nred open: not in main fit (birds, mammals: S9; prokaryotes: S12)") +
    ggplot2::theme_bw(9)
  ggplot2::ggsave(out, p, width = 10, height = 8, device = grDevices::cairo_pdf); out
}
ggrepel_text <- function(d) ggplot2::geom_text(ggplot2::aes(label = label), size = 2.5, vjust = -0.8)

fig_sensitivity <- function(sumtab, s13, out = "figs/phase4_sensitivity_beta.pdf") {
  d <- dplyr::bind_rows(sumtab, s13) |> dplyr::filter(type %in% c("all", "human_obs", "dna")) |>
    dplyr::mutate(analysis = factor(analysis, levels = rev(unique(analysis))))
  p <- ggplot2::ggplot(d, ggplot2::aes(beta_med, analysis, colour = type)) +
    ggplot2::geom_vline(xintercept = 2/3, linetype = 2) +
    ggplot2::geom_pointrange(ggplot2::aes(xmin = beta_lo, xmax = beta_hi), position = ggplot2::position_dodge(width = 0.6), size = 0.2) +
    ggplot2::labs(x = "β (slope of log r on log M), 95% CrI", y = NULL) + ggplot2::theme_bw(8)
  ggplot2::ggsave(out, p, width = 7, height = 9, device = grDevices::cairo_pdf); out
}

fig_tierA <- function(dm, out = "figs/phase4_tierA_mammals.pdf") {
  d <- dplyr::mutate(dm, log10r = log10((R + 0.5) / N), log10M = log10(M_g))
  p <- ggplot2::ggplot(d, ggplot2::aes(log10M, log10r)) + ggplot2::geom_point(alpha = 0.5, size = 1) +
    ggplot2::geom_smooth(method = "lm", formula = y ~ x, se = FALSE, colour = "grey30", linewidth = 0.5) +
    ggplot2::labs(x = "log10 body mass (g)", y = "log10 (R+0.5)/N, 2000–2024",
                  caption = "Report-based mammal species (Greenspoon 2023); line: descriptive OLS only (model estimate in models/tierA_summary.csv)") +
    ggplot2::theme_bw(9)
  ggplot2::ggsave(out, p, width = 6, height = 5, device = grDevices::cairo_pdf); out
}
