# 改訂（Reviewer 4）：GBIF の非構造化記録から推定した傾向を、構造化モニタリング（UKBMS）と比べる
# 英国のチョウ、2000–2019 年（非構造化記録の最大データセットが 2019 年で終わるため）
# データ：range-shift-null プロジェクトの GB チョウ記録（GBIF DOI 10.15468/dl.u8s7s5、is_structured で UKBMS/WCBS を区別）と
#        UKBMS 2024 のサイト指数（ukbmssiteindices2024.csv）
suppressPackageStartupMessages({ library(dplyr); library(tidyr) })
rs <- "/home/bi_core9_1_guest/claude_core9/range-shift-null"
yrs <- 2000:2019
occ <- arrow::open_dataset(file.path(rs, "data/interim/occ_clean.parquet")) |>
  filter(year >= 2000, year <= 2019, !is_structured) |> group_by(species, year) |> summarise(y = n()) |> collect()
tot <- occ |> group_by(year) |> summarise(G = sum(y))
si <- readr::read_csv(file.path(rs, "data/raw/ukbms/53a1c705-4437-48bb-9bcd-b68977f8edd9/data/ukbmssiteindices2024.csv"), show_col_types = FALSE) |>
  filter(YEAR %in% yrs, !is.na(SITE_INDEX), SITE_INDEX >= 0)   # -2 = 監視不足で指数なし（UKBMS の説明書）
sp <- intersect(unique(si$SPECIES), unique(occ$species))
one <- function(s) {
  # UKBMS：サイト指数の Poisson GLM（site 効果 + 年の線形項、準ポアソンの SE）
  u <- filter(si, SPECIES == s) |> group_by(SITE_CODE) |> filter(sum(SITE_INDEX) > 0, n() >= 3) |> ungroup()
  fu <- tryCatch(glm(SITE_INDEX ~ factor(SITE_CODE) + YEAR, family = quasipoisson(), data = u), error = function(e) NULL)
  cu <- if (is.null(fu)) c(NA, NA) else summary(fu)$coefficients["YEAR", 1:2]
  g <- tibble(year = yrs) |> left_join(filter(occ, species == s), by = "year") |> mutate(y = coalesce(y, 0L)) |> left_join(tot, by = "year")
  t <- g$year - 2000
  fa <- tryCatch(MASS::glm.nb(y ~ t + offset(log(G)), data = g), error = function(e) NULL)
  fc <- tryCatch(MASS::glm.nb(y ~ t, data = g), error = function(e) NULL)
  fb <- tryCatch(glm(cbind(y, G - y) ~ t, family = binomial(), data = g), error = function(e) NULL)
  co <- function(f) if (is.null(f)) c(NA, NA) else summary(f)$coefficients["t", 1:2]
  ca <- co(fa); cb <- co(fb); cc <- co(fc)
  # GBIF の残差の自己相関（方法 a、ピアソン残差のラグ 1）
  ac <- if (is.null(fa)) NA else { r <- residuals(fa, type = "pearson"); cor(r[-1], r[-length(r)]) }
  tibble(species = s, n_sites = n_distinct(u$SITE_CODE), gbif_mean = mean(g$y), phi_a = if (is.null(fa)) NA else fa$theta, ac1_a = ac,
         ukbms_b = cu[1], ukbms_se = cu[2], a_b = ca[1], a_se = ca[2], b_b = cb[1], b_se = cb[2], c_b = cc[1], c_se = cc[2])
}
res <- bind_rows(parallel::mclapply(sp, one, mc.cores = 8, mc.preschedule = FALSE))
z <- qnorm(0.975)
res <- res |> mutate(uk_sig = case_when(ukbms_b / ukbms_se < -z ~ "decline", ukbms_b / ukbms_se > z ~ "increase", TRUE ~ "ns"))
for (m in c("a", "b", "c")) res[[paste0(m, "_sig")]] <- with(res, case_when(get(paste0(m, "_b")) / get(paste0(m, "_se")) < -z ~ "decline",
                                                                           get(paste0(m, "_b")) / get(paste0(m, "_se")) > z ~ "increase", TRUE ~ "ns"))
summ <- purrr::map(c("a", "b", "c"), function(m) {
  b <- res[[paste0(m, "_b")]]; s <- res[[paste0(m, "_sig")]]
  tibble(method = m, n_species = sum(!is.na(b) & !is.na(res$ukbms_b)),
         pearson_slopes = cor(b, res$ukbms_b, use = "complete.obs"), spearman_slopes = cor(b, res$ukbms_b, use = "complete.obs", method = "spearman"),
         uk_declines = sum(res$uk_sig == "decline"), detected_of_uk_declines = sum(res$uk_sig == "decline" & s == "decline"),
         uk_not_declining = sum(res$uk_sig != "decline"), false_declines = sum(res$uk_sig != "decline" & s == "decline"),
         opposite_sign_sig = sum((res$uk_sig == "decline" & s == "increase") | (res$uk_sig == "increase" & s == "decline")))
}) |> bind_rows()
print(summ)
cat("GBIF method a: median phi", median(res$phi_a, na.rm = TRUE), " median lag-1 autocorrelation", median(res$ac1_a, na.rm = TRUE), "\n")
readr::write_csv(res, "sim/rev_validation_ukbms_species.csv"); readr::write_csv(summ, "sim/rev_validation_ukbms_summary.csv")
