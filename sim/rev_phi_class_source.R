# 改訂（Reviewer 4）：分類群とデータ源ごとの φ（種ごとの線形傾向を除く版も）。鳥類（eBird/非 eBird）と哺乳類
source("sim/explore_common.R")
set.seed(20261103)
tar_load(c(bird_gy, mam_gy))
mk <- function(gy, label, filt = identity) {
  gy |> filt() |> filter(year %in% 2000:2024, rtype != "fossil") |> group_by(sp = species, year) |> summarise(y = sum(n), .groups = "drop") |>
    complete(sp, year = 2000:2024, fill = list(y = 0)) |> group_by(sp) |> mutate(m = mean(y)) |> ungroup() |>
    mutate(set = label, t = (year - 2012) / 12, stratum = cut(m, c(0, 1, 10, 100, Inf), right = FALSE, labels = c("<1", "1-10", "10-100", ">=100")))
}
d <- bind_rows(mk(bird_gy, "birds: all"), mk(bird_gy, "birds: eBird only", \(x) filter(x, ds_class == "ebird")),
               mk(bird_gy, "birds: excluding eBird", \(x) filter(x, ds_class != "ebird")),
               mk(mam_gy, "mammals: all"), mk(mam_gy, "mammals: excluding machine obs.", \(x) filter(x, basisofrecord != "MACHINE_OBSERVATION")))
fitphi <- function(x, form) tryCatch(MASS::glm.nb(form, data = x, control = glm.control(maxit = 100))$theta, error = function(e) NA_real_)
ac1 <- function(x) { f <- tryCatch(MASS::glm.nb(y ~ 0 + factor(sp) + factor(year) + factor(sp):t, data = x), error = function(e) NULL)
  if (is.null(f)) return(NA); r <- residuals(f, type = "pearson"); x$r <- r
  x |> arrange(sp, year) |> group_by(sp) |> summarise(a = if (sd(r) > 0) cor(r[-1], r[-n()]) else NA) |> pull(a) |> median(na.rm = TRUE) }
res <- d |> group_by(set, stratum) |> group_modify(function(x, k) {
  s <- unique(x$sp); if (length(s) < 5) return(tibble())
  x <- filter(x, sp %in% sample(s, min(250, length(s))))
  tibble(n_species = n_distinct(x$sp), mean_rec = mean(x$y),
         phi_base = fitphi(x, y ~ 0 + factor(sp) + factor(year)), phi_linear = fitphi(x, y ~ 0 + factor(sp) + factor(year) + factor(sp):t),
         lag1_ac = ac1(x))
}) |> ungroup()
print(res, n = 40)
readr::write_csv(res, "sim/rev_phi_class_source.csv")
