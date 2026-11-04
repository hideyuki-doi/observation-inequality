# Phase 5 の図
fig_tdetect_lambda <- function(grid, out = "figs/phase5_tdetect_vs_lambda.pdf") {
  d <- grid |> dplyr::filter(scenario == "E_flat", phi == min(phi[scenario == "E_flat"]) | TRUE) |>
    tidyr::pivot_longer(c(T_a, T_b, T_c), names_to = "method", values_to = "T") |>
    dplyr::mutate(T = pmin(T, 110), method = dplyr::recode(method, T_a = "(a) effort offset", T_b = "(b) relative reporting rate", T_c = "(c) raw counts"))
  d <- dplyr::filter(d, abs(phi - median(unique(grid$phi))) < 1e-9 | length(unique(grid$phi)) == 1)
  p <- ggplot2::ggplot(d, ggplot2::aes(log10(lambda0), T, colour = group_id)) + ggplot2::geom_line() +
    ggplot2::geom_hline(yintercept = c(25, 100), linetype = 3) + ggplot2::facet_wrap(~method) +
    ggplot2::labs(x = "log10 initial expected records per species-year (λ0)", y = "years to detect 30%/10 yr decline (power 0.8); 110 = never within 100",
                  colour = NULL) + ggplot2::theme_bw(9, base_family = "Helvetica")
  ggplot2::ggsave(out, p, width = 11, height = 4.5, device = grDevices::cairo_pdf); out
}

fig_tdetect_mass <- function(gu, out = "figs/phase5_undetectable_vs_mass.pdf") {
  d <- dplyr::filter(gu, method == "T_a")
  p <- ggplot2::ggplot(d, ggplot2::aes(log10M, undetect25_med, colour = factor(sigma10))) +
    ggplot2::geom_pointrange(ggplot2::aes(ymin = undetect25_lo, ymax = undetect25_hi), position = ggplot2::position_dodge(width = 0.25), size = 0.25) +
    ggplot2::geom_text(data = dplyr::filter(d, sigma10 == 1.5), ggplot2::aes(label = group_id), colour = "black", size = 2.5, vjust = -1.2) +
    ggplot2::scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
    ggplot2::labs(x = "log10 body mass M (g wet)", y = "species whose 30%/10-yr decline is not detected within 25 years",
                  colour = "SAD σ (log10)", caption = "method (a): NB-GLM with effort offset (best case); posterior median and 95% interval") +
    ggplot2::theme_bw(9, base_family = "Helvetica")
  ggplot2::ggsave(out, p, width = 7, height = 5, device = grDevices::cairo_pdf); out
}
