# 改訂の主解析：種あたりの記録数（記載種すべて、記録のない種は 0）をグループ間で比べる。記録数と記載種数の関係
source("sim/explore_common.R")
tar_load(c(group_recs, census_main, p5_S))
grp <- tibble(group_id = c("soil_nematodes", "springtails", "mites", "ants", "enchytraeids", "copepods", "pteropods", "jellyfish", "mesopelagic_fish", "krill", "mammals", "birds"),
              variant = c(rep("main", 8), "myctophidae_only", "main", "main", "main"))
S <- c(p5_S, mammals = 6368, birds = 10868); S["jellyfish"] <- 297   # 箱虫類を加える（Reviewer 2）   # 哺乳類・鳥類は Catalogue of Life（docs/provenance_parts/harmonized.csv）
M <- census_main |> filter(role == "main") |> transmute(group_id, log10M = log10(M_g_wet))
# 哺乳類・鳥類の M は種の体重の中央値（COMBINE、AVONET）
tar_load(c(mam_sp, bird_sp)); M <- bind_rows(M, tibble(group_id = c("mammals", "birds"), log10M = log10(c(median(mam_sp$M_g, na.rm = TRUE), median(bird_sp$M_g, na.rm = TRUE)))))
x <- group_recs |> semi_join(grp, by = c("group_id", "variant")) |> filter(rtype != "fossil")
R_all <- x |> filter(year %in% 2000:2024) |> group_by(group_id) |> summarise(R = sum(as.numeric(n)))
lam <- x |> filter(!is.na(specieskey), specieskey != "", year %in% 2015:2024) |> group_by(group_id, specieskey) |> summarise(lambda = sum(n) / 10, .groups = "drop")
summ <- lam |> group_by(group_id) |> summarise(recorded = n(), lam = list(lambda), .groups = "drop") |>
  mutate(S = S[group_id], unrecorded = pmax(S - recorded, 0)) |> rowwise() |>
  mutate(all = list(c(lam, rep(0, unrecorded))),
         share_zero = unrecorded / (recorded + unrecorded), median_all = median(all), mean_all = mean(all),
         q75_all = quantile(all, .75), q90_all = quantile(all, .9), median_recorded = median(lam),
         share_lt_0.32_all = mean(all < 0.32), share_lt_0.32_recorded = mean(lam < 0.32)) |>
  ungroup() |> select(-lam, -all) |> left_join(R_all, by = "group_id") |> left_join(M, by = "group_id") |>
  mutate(R_per_species = R / 25 / S) |> arrange(log10M)
print(summ, width = 200)
readr::write_csv(summ, "sim/rev_species_rates.csv")
inv <- filter(summ, !group_id %in% c("mammals", "birds"), S > 1)
f <- lm(log10(R) ~ log10(S), data = inv); print(summary(f)$coefficients); cat("R2", summary(f)$r.squared, "\n")
pred <- predict(f, newdata = filter(summ, group_id %in% c("mammals", "birds")))
cat("vertebrate excess over invertebrate R~S relation (log10):", round(log10(summ$R[summ$group_id %in% c("mammals","birds")]) - pred, 2), "\n")
