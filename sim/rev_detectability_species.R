# 改訂の主結果：記載種ごとの実際の記録率（2015–2024）と、分類群・記録の多さ別の φ による検出年数曲線から、
# 「10 年で 30% の減少を、何年以内に検出できるか」を種ごとに求めて集計する
source("sim/explore_common.R")
tg <- readr::read_csv("sim/rev_tdetect_phi_lambda.csv", show_col_types = FALSE)
Tof <- function(set, lam) { g <- tg[tg$set == set, ] |> arrange(lambda0); i <- findInterval(lam, g$lambda0); ifelse(i == 0, Inf, g$T_a[pmax(i, 1)]) }  # 格子の下側の点（保守的）
tar_load(c(group_recs, p5_S, mam_sp, mam_gy, bird_sp, bird_gy, census_main))
grp <- tibble(group_id = c("soil_nematodes", "springtails", "mites", "ants", "enchytraeids", "copepods", "pteropods", "jellyfish", "mesopelagic_fish"),
              variant = c(rep("main", 8), "myctophidae_only"))
S <- p5_S; S["jellyfish"] <- 297   # 箱虫類を加える（Reviewer 2）
lam <- group_recs |> semi_join(grp, by = c("group_id", "variant")) |> filter(rtype != "fossil", !is.na(specieskey), specieskey != "", year %in% 2015:2024) |>
  group_by(group_id, specieskey) |> summarise(lambda = sum(n) / 10, .groups = "drop")
inv <- lam |> group_by(group_id) |> group_modify(function(x, k) { z <- max(S[k$group_id] - nrow(x), 0); tibble(lambda = c(x$lambda, rep(0, z))) }) |> ungroup() |>
  mutate(set = group_id)
M <- census_main |> filter(role == "main") |> transmute(group_id, log10M = log10(M_g_wet))
inv <- left_join(inv, M, by = "group_id")
vsp <- function(sp, gy, set, label) { l <- gy |> filter(year %in% 2015:2024, rtype != "fossil") |> group_by(species) |> summarise(lambda = sum(n) / 10)
  sp |> filter(!is.na(M_g)) |> distinct(gbif_name, .keep_all = TRUE) |> left_join(l, by = c("gbif_name" = "species")) |>
    transmute(group_id = label, lambda = coalesce(lambda, 0), log10M = log10(M_g), set = set) }
vert <- bind_rows(vsp(mam_sp, mam_gy, "mammals", "mammals"), vsp(bird_sp, bird_gy, "birds (eBird)", "birds"))
all <- bind_rows(inv, vert) |> group_by(set) |> mutate(T = Tof(first(set), lambda)) |> ungroup() |>
  mutate(class = case_when(lambda == 0 ~ "never recorded", is.infinite(T) | T > 100 ~ "recorded, >100 yr", T > 50 ~ "51–100 yr", T > 25 ~ "26–50 yr", TRUE ~ "≤25 yr"))
summ_g <- all |> filter(!group_id %in% c("mammals", "birds")) |> count(group_id, log10M, class) |> group_by(group_id) |> mutate(share = n / sum(n)) |> ungroup()
summ_v <- all |> filter(group_id %in% c("mammals", "birds")) |> mutate(bin = floor(log10M) + 0.5) |> count(group_id, bin, class) |>
  group_by(group_id, bin) |> mutate(share = n / sum(n), n_bin = sum(n)) |> ungroup() |> filter(n_bin >= 20)
tot <- all |> group_by(group_id) |> summarise(n = n(), never_recorded = mean(class == "never recorded"),
                                              undetectable_100 = mean(class %in% c("never recorded", "recorded, >100 yr")),
                                              within_50 = mean(class %in% c("26–50 yr", "≤25 yr")), within_25 = mean(class == "≤25 yr"),
                                              undetectable_100_among_recorded = mean(class[lambda > 0] == "recorded, >100 yr"))
print(tot, n = 20)
readr::write_csv(summ_g, "sim/rev_detectability_groups.csv"); readr::write_csv(summ_v, "sim/rev_detectability_vert_bins.csv"); readr::write_csv(tot, "sim/rev_detectability_totals.csv")
