# 改訂版の主図（コードから生成）
theme_rev <- function() ggplot2::theme_bw(9) + ggplot2::theme(panel.grid.minor = ggplot2::element_blank())
lab_g <- c(soil_nematodes = "Nematodes", mites = "Mites", copepods = "Copepods", springtails = "Springtails", enchytraeids = "Enchytraeids",
           ants = "Ants", pteropods = "Pteropods", jellyfish = "Jellyfish", krill = "Antarctic krill", mesopelagic_fish = "Mesopelagic fish",
           mammals = "Mammals", birds = "Birds")

# 図1：記録は種に配分され、個体には配分されない
fig_rev1 <- function(rates, census, free, out = "figs/rev_main_1_records.pdf") {
  r <- rates |> dplyr::mutate(vert = group_id %in% c("mammals", "birds"))
  inv <- dplyr::filter(r, !vert, S > 1); fit <- lm(log10(R) ~ log10(S), data = inv)
  pa <- ggplot2::ggplot(dplyr::filter(r, S > 1), ggplot2::aes(log10(S), log10(R))) +
    ggplot2::geom_abline(intercept = coef(fit)[1], slope = coef(fit)[2], colour = "grey40") +
    ggplot2::geom_point(ggplot2::aes(shape = vert, colour = vert), size = 2.2) +
    ggplot2::geom_text(ggplot2::aes(label = lab_g[group_id]), size = 2.4, vjust = -0.9) +
    ggplot2::scale_colour_manual(values = c(`FALSE` = "black", `TRUE` = "#b2182b"), guide = "none") +
    ggplot2::scale_shape_manual(values = c(`FALSE` = 16, `TRUE` = 17), guide = "none") +
    ggplot2::annotate("text", x = -Inf, y = Inf, hjust = -0.05, vjust = 1.3, size = 2.6,
                      label = sprintf("invertebrate groups: slope %.2f (R² = %.2f)", coef(fit)[2], summary(fit)$r.squared)) +
    ggplot2::labs(x = expression(log[10]~"described species"), y = expression(log[10]~"GBIF records 2000–2024"), tag = "a") + theme_rev()
  cn <- census |> dplyr::filter(role == "main") |> dplyr::select(group_id, N) |> dplyr::left_join(r, by = "group_id")
  pb <- ggplot2::ggplot(cn, ggplot2::aes(log10(N), log10(R))) +
    ggplot2::geom_abline(intercept = mean(log10(cn$R)) - mean(log10(cn$N)), slope = 1, linetype = 2, colour = "grey50") +
    ggplot2::geom_point(size = 2.2) + ggplot2::geom_text(ggplot2::aes(label = lab_g[group_id]), size = 2.4, vjust = -0.9) +
    ggplot2::annotate("text", x = Inf, y = -Inf, hjust = 1.05, vjust = -0.6, size = 2.6, label = "dashed: records proportional to individuals") +
    ggplot2::labs(x = expression(log[10]~"census abundance (individuals)"), y = expression(log[10]~"GBIF records 2000–2024"), tag = "b") + theme_rev()
  fc <- free |> dplyr::filter(model == "free: N + M + log S") |>
    dplyr::mutate(param = factor(param, c("gamma (lnN)", "delta (lnM)", "lnS"), c("abundance (γ)", "body mass (δ)", "described species")))
  pc <- ggplot2::ggplot(fc, ggplot2::aes(med, param)) + ggplot2::geom_vline(xintercept = c(0, 1), linetype = c(1, 2), colour = "grey60") +
    ggplot2::geom_pointrange(ggplot2::aes(xmin = lo, xmax = hi)) +
    ggplot2::labs(x = "coefficient on log records (95% CrI)", y = NULL, tag = "c") + theme_rev()
  p <- patchwork::wrap_plots(pa, pb, pc, widths = c(1.15, 1.15, 0.9)) +
    patchwork::plot_annotation(caption = "(a) Records against described species for invertebrate and small marine groups (circles, line) and vertebrates (triangles).\n(b) Records against census abundance for the ten groups with independent censuses. (c) Errors-in-variables model of log records on log abundance, log body mass and log described species.")
  ggplot2::ggsave(out, p, width = 11, height = 4.2, device = grDevices::cairo_pdf); out
}

# 図2：検出年数は記録の多さと過分散で決まり、構造化モニタリングとの一致も弱い
fig_rev2 <- function(tg, phis, uk, ukm, out = "figs/rev_main_2_detection.pdf") {
  sel <- c("soil_nematodes", "mites", "ants", "mammals", "birds (eBird)")
  lab2 <- c(lab_g, `birds (eBird)` = "Birds (eBird)", `birds (excluding eBird)` = "Birds (other)")
  g <- dplyr::filter(tg, set %in% sel) |> dplyr::mutate(T = pmin(T_a, 105), set = factor(set, sel))
  pa <- ggplot2::ggplot(g, ggplot2::aes(log10(lambda0), T, colour = set)) + ggplot2::geom_step(direction = "mid") +
    ggplot2::geom_hline(yintercept = c(25, 100), linetype = 3) +
    ggplot2::scale_colour_manual(values = c("#542788", "#8073ac", "#e08214", "#1b7837", "#b2182b"), labels = lab2[sel], name = NULL) +
    ggplot2::labs(x = expression(log[10]~"records per species-year"), y = "years to detect a 30% decline per decade", tag = "a") +
    theme_rev() + ggplot2::theme(legend.position = c(0.72, 0.72), legend.background = ggplot2::element_blank())
  ph <- dplyr::filter(phis, n_species >= 10, !is.na(phi_linear), !grepl("no machine", set)) |>
    dplyr::mutate(stratum = factor(stratum, c("1-10", "10-100", ">=100")), vert = grepl("mammals|birds", set))
  pb <- ggplot2::ggplot(ph, ggplot2::aes(stratum, phi_linear, group = set, colour = vert)) + ggplot2::geom_line(alpha = 0.7) + ggplot2::geom_point() +
    ggplot2::scale_y_log10() + ggplot2::scale_colour_manual(values = c(`FALSE` = "grey30", `TRUE` = "#b2182b"), labels = c("invertebrates & fish", "mammals & birds"), name = NULL) +
    ggplot2::labs(x = "records per species-year", y = "overdispersion φ (log scale)", tag = "b") + theme_rev() +
    ggplot2::theme(legend.position = c(0.35, 0.85), legend.background = ggplot2::element_blank())
  u <- dplyr::mutate(uk, uk_sig = factor(uk_sig, c("decline", "ns", "increase"), c("UKBMS decline", "UKBMS no trend", "UKBMS increase")))
  pc <- ggplot2::ggplot(u, ggplot2::aes(100 * ukbms_b, 100 * a_b, colour = uk_sig, shape = a_sig == "decline")) +
    ggplot2::geom_hline(yintercept = 0, colour = "grey70") + ggplot2::geom_vline(xintercept = 0, colour = "grey70") +
    ggplot2::geom_abline(linetype = 2, colour = "grey50") + ggplot2::geom_point(size = 2) +
    ggplot2::scale_colour_manual(values = c("#b2182b", "grey50", "#2166ac"), name = NULL) +
    ggplot2::scale_shape_manual(values = c(`FALSE` = 1, `TRUE` = 16), labels = c("not flagged", "flagged as declining"), name = "GBIF records") +
    ggplot2::annotate("text", x = -Inf, y = Inf, hjust = -0.05, vjust = 1.3, size = 2.5,
                      label = sprintf("r = %.2f; declines detected %d/%d;\nfalse declines %d/%d", ukm$pearson_slopes[ukm$method == "a"],
                                      ukm$detected_of_uk_declines[ukm$method == "a"], ukm$uk_declines[ukm$method == "a"],
                                      ukm$false_declines[ukm$method == "a"], ukm$uk_not_declining[ukm$method == "a"])) +
    ggplot2::labs(x = "UKBMS trend (% per year)", y = "trend from GBIF records (% per year)", tag = "c") + theme_rev() +
    ggplot2::theme(legend.position = "right", legend.key.size = ggplot2::unit(0.35, "cm"))
  p <- patchwork::wrap_plots(pa, pb, pc, widths = c(1.1, 0.8, 1.3)) +
    patchwork::plot_annotation(caption = "(a) Simulated years to detect a 30% decline per decade (power 0.8; negative binomial regression with effort offset; constant effort), using overdispersion\nestimated for each group and record rate after removing species-specific trends. 105 = not within 100 years. (b) Overdispersion of annual record counts by record rate.\n(c) British butterflies 2000–2019: trends from unstructured GBIF records (effort offset) vs the UK Butterfly Monitoring Scheme (48 species).")
  ggplot2::ggsave(out, p, width = 12, height = 4.4, device = grDevices::cairo_pdf); out
}

mass_lab <- function(lo) c(`-1` = "0.1–1 g", `0` = "1–10 g", `1` = "10–100 g", `2` = "0.1–1 kg", `3` = "1–10 kg", `4` = "10–100 kg", `5` = "0.1–1 t", `6` = "1–10 t", `7` = "10–100 t")[as.character(lo)]

# 図3：種ごとの検出可能性（記載種すべて）と DNA 記録の体サイズ依存
fig_rev3 <- function(dg, dv, tab, census, h4, out = "figs/rev_main_3_detectability.pdf") {
  cls <- c("≤25 yr", "26–50 yr", "51–100 yr", "recorded, >100 yr", "never recorded")
  pal <- c("#1a9850", "#a6d96a", "#fee08b", "#f46d43", "#a50026")
  a <- dplyr::bind_rows(dplyr::mutate(dg, x = lab_g[group_id], o = log10M),
                        dplyr::mutate(dv, x = paste0(ifelse(group_id == "mammals", "Mammals ", "Birds "), mass_lab(bin - 0.5)),
                                      o = bin + ifelse(group_id == "birds", 10, 20))) |>
    dplyr::mutate(class = factor(class, rev(cls)), x = forcats::fct_reorder(x, o))
  pa <- ggplot2::ggplot(a, ggplot2::aes(x, share, fill = class)) + ggplot2::geom_col(width = 0.85) +
    ggplot2::scale_fill_manual(values = setNames(pal, cls), breaks = cls, name = "decline detectable within") +
    ggplot2::scale_y_continuous(labels = scales::percent, expand = c(0, 0)) +
    ggplot2::labs(x = NULL, y = "share of described species", tag = "a") + theme_rev() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 60, hjust = 1, size = 7))
  cm <- census |> dplyr::filter(role == "main") |> dplyr::transmute(group_id, log10M = log10(M_g_wet))
  d <- tab |> dplyr::left_join(cm, by = "group_id") |>
    dplyr::mutate(meta = log10((dna_metabarcoding + 0.5) / (human_obs + 0.5)), barcode = log10((dna_barcode + 0.5) / (human_obs + 0.5))) |>
    tidyr::pivot_longer(c(meta, barcode), names_to = "type", values_to = "y") |>
    dplyr::mutate(type = factor(type, c("meta", "barcode"), c("metabarcoding / eDNA", "specimen barcodes (iBOL)")))
  lab <- h4 |> dplyr::filter(grepl("metabarcoding|barcode", contrast)) |>
    dplyr::mutate(type = ifelse(grepl("metabarcoding", contrast), "metabarcoding / eDNA", "specimen barcodes (iBOL)"),
                  txt = sprintf("slope %.2f [%.2f, %.2f]", slope, lo, hi))
  pb <- ggplot2::ggplot(d, ggplot2::aes(log10M, y)) + ggplot2::geom_smooth(method = "lm", formula = y ~ x, se = FALSE, colour = "grey30", linewidth = 0.5) +
    ggplot2::geom_point() + ggplot2::geom_text(ggplot2::aes(label = lab_g[group_id]), size = 2.2, vjust = -0.8) +
    ggplot2::facet_wrap(~type, ncol = 1) +
    ggplot2::geom_text(data = lab, ggplot2::aes(x = -Inf, y = -Inf, label = txt), hjust = -0.05, vjust = -0.6, size = 2.5, inherit.aes = FALSE) +
    ggplot2::labs(x = expression(log[10]~"body mass (g)"), y = expression(log[10]~"DNA-derived / human-observation records"), tag = "b") + theme_rev()
  p <- patchwork::wrap_plots(pa, pb, widths = c(2.2, 1)) +
    patchwork::plot_annotation(caption = "(a) For every described species, the time needed to detect a 30% decline per decade from its observed GBIF record rate (2015–2024), using the curves in Fig. 2a.\nInvertebrate and small marine groups ordered by typical body mass; mammals and birds by body-mass class. (b) Ratio of DNA-derived to human-observation records against body mass\n(abundance cancels in the ratio); slopes with 95% intervals propagating census and residual uncertainty.")
  ggplot2::ggsave(out, p, width = 12, height = 5.2, device = grDevices::cairo_pdf); out
}

# 図1（v3）：1 個体あたりの観測の不平等（記述）と、その原因が種への配分であること
fig_rev1_v3 <- function(pts, vert, rates, census, free, out = "figs/rev3_main_1_inequality.pdf") {
  d <- dplyr::filter(pts, analysis == "main", type == "all")
  v <- dplyr::filter(vert, set %in% c("census_independent", "report_land")) |> dplyr::mutate(log10r = log10((R + 0.5) / N))
  nem <- d$log10r_med[d$label == "soil_nematodes"]; mam <- median(v$log10r[v$set == "census_independent"])
  pa <- ggplot2::ggplot() +
    ggplot2::geom_point(data = v, ggplot2::aes(log10M, log10r, colour = set), size = 0.8, alpha = 0.55) +
    ggplot2::scale_colour_manual(values = c(census_independent = "#1f78b4", report_land = "#a6cee3"),
                                 labels = c("Mammal species, survey-based census", "Mammal species, reported populations"), name = NULL) +
    ggplot2::geom_errorbar(data = d, ggplot2::aes(x = log10M_med, ymin = log10r_lo, ymax = log10r_hi), width = 0, colour = "grey40") +
    ggplot2::geom_point(data = d, ggplot2::aes(log10M_med, log10r_med), size = 2) +
    ggplot2::geom_text(data = d, ggplot2::aes(log10M_med, log10r_med, label = lab_g[label]), size = 2.3, hjust = -0.12, vjust = 1.3) +
    ggplot2::annotate("segment", x = 7.6, xend = 7.6, y = nem, yend = mam, arrow = ggplot2::arrow(ends = "both", length = ggplot2::unit(0.15, "cm")), colour = "#b2182b") +
    ggplot2::annotate("text", x = 7.4, y = (nem + mam) / 2, label = sprintf("~10^%.0f", mam - nem), parse = TRUE, hjust = 1, colour = "#b2182b", size = 3) +
    ggplot2::labs(x = expression(log[10]~"body mass (g)"), y = expression(log[10]~"GBIF records per individual, 2000–2024"), tag = "a") + theme_rev() +
    ggplot2::theme(legend.position = c(0.32, 0.9), legend.background = ggplot2::element_blank(), legend.key.size = ggplot2::unit(0.3, "cm"))
  r <- rates |> dplyr::mutate(vert = group_id %in% c("mammals", "birds"))
  inv <- dplyr::filter(r, !vert, S > 1); fit <- lm(log10(R) ~ log10(S), data = inv)
  pb <- ggplot2::ggplot(dplyr::filter(r, S > 1), ggplot2::aes(log10(S), log10(R))) +
    ggplot2::geom_abline(intercept = coef(fit)[1], slope = coef(fit)[2], colour = "grey40") +
    ggplot2::geom_point(ggplot2::aes(shape = vert, colour = vert), size = 2.2) +
    ggplot2::geom_text(ggplot2::aes(label = lab_g[group_id]), size = 2.3, vjust = -0.9) +
    ggplot2::scale_colour_manual(values = c(`FALSE` = "black", `TRUE` = "#b2182b"), guide = "none") +
    ggplot2::scale_shape_manual(values = c(`FALSE` = 16, `TRUE` = 17), guide = "none") +
    ggplot2::annotate("text", x = -Inf, y = Inf, hjust = -0.05, vjust = 1.3, size = 2.5,
                      label = sprintf("invertebrate and fish groups: slope %.2f (R² = %.2f)", coef(fit)[2], summary(fit)$r.squared)) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = 0.08)) +
    ggplot2::labs(x = expression(log[10]~"described species"), y = expression(log[10]~"GBIF records 2000–2024"), tag = "b") + theme_rev()
  cn <- census |> dplyr::filter(role == "main") |> dplyr::select(group_id, N) |> dplyr::left_join(r, by = "group_id")
  pc <- ggplot2::ggplot(cn, ggplot2::aes(log10(N), log10(R))) +
    ggplot2::geom_abline(intercept = mean(log10(cn$R)) - mean(log10(cn$N)), slope = 1, linetype = 2, colour = "grey50") +
    ggplot2::geom_point(size = 2.2) + ggplot2::geom_text(ggplot2::aes(label = lab_g[group_id]), size = 2.3, vjust = -0.9) +
    ggplot2::coord_cartesian(ylim = range(log10(cn$R)) + c(-0.3, 0.4)) +
    ggplot2::annotate("text", x = Inf, y = -Inf, hjust = 1.05, vjust = -0.6, size = 2.5, label = "dashed: records proportional to individuals") +
    ggplot2::labs(x = expression(log[10]~"census abundance (individuals)"), y = expression(log[10]~"GBIF records 2000–2024"), tag = "c") + theme_rev()
  fc <- free |> dplyr::filter(model == "free: N + M + log S") |>
    dplyr::mutate(param = factor(param, c("gamma (lnN)", "delta (lnM)", "lnS"), c("abundance", "body mass", "described species")))
  pd <- ggplot2::ggplot(fc, ggplot2::aes(med, param)) + ggplot2::geom_vline(xintercept = 0, colour = "grey60") +
    ggplot2::geom_vline(xintercept = 1, linetype = 2, colour = "grey60") +
    ggplot2::geom_pointrange(ggplot2::aes(xmin = lo, xmax = hi)) +
    ggplot2::annotate("text", x = 1, y = 3.45, label = "proportional", size = 2.4, colour = "grey40", hjust = 1.05) +
    ggplot2::coord_cartesian(xlim = c(-1, 1.1)) +
    ggplot2::labs(x = "coefficient on log records (95% CrI)", y = NULL, tag = "d") + theme_rev()
  p <- patchwork::wrap_plots(pa, pb, pc, pd, ncol = 2, widths = c(1.25, 1))
  ggplot2::ggsave(out, p, width = 10, height = 8, device = grDevices::cairo_pdf); out
}
