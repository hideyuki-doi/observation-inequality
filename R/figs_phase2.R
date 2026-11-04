# Phase 2 診断図：グループ別・年別・記録種類別の GBIF 記録数
fig_records_by_year <- function(rg, out = "figs/phase2_records_by_year.pdf") {
  d <- rg |> dplyr::filter(variant %in% c("main", "myctophidae_only"), year >= 1950, year <= 2025) |>
    dplyr::group_by(group_id, year, rtype) |> dplyr::summarise(n = sum(n), .groups = "drop")
  p <- ggplot2::ggplot(d, ggplot2::aes(year, n, colour = rtype)) + ggplot2::geom_line() +
    ggplot2::scale_y_log10() + ggplot2::facet_wrap(~group_id, scales = "free_y") +
    ggplot2::annotate("rect", xmin = 2000, xmax = 2024, ymin = 0, ymax = Inf, alpha = 0.08) +
    ggplot2::labs(y = "GBIF records per year (log)", colour = "record type") + ggplot2::theme_bw(9, base_family = "Times New Roman")
  ggplot2::ggsave(out, p, width = 11, height = 8, device = grDevices::cairo_pdf)
  out
}
