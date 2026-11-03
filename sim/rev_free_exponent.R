# 改訂（Reviewers 1, 3, 5, 6）：比の人工物の検証
# (1) 記録数 R を、個体数 N・体重 M・記載種数 S・生息場所に対して自由係数で回帰（EIV、全記録のみ、種類ごとの同時当てはめはしない）
# (2) 「記録数がどのグループでも同じ」帰無モデルでの β の分布（記録数の並べ替え）
source("sim/explore_common.R")
tar_load(c(tb_obs, tb_R, p5_S))
labs <- sort(unique(tb_obs$label)); R <- tb_R$all[match(labs, tb_R$label)]
S <- p5_S[labs]; S["jellyfish"] <- 297   # 箱虫類を加える（QA で不一致を修正）
habitat_soil <- as.numeric(labs %in% c("soil_nematodes", "springtails", "mites", "ants", "enchytraeids"))
lnM_obs <- vapply(labs, \(l) { o <- tb_obs[tb_obs$label == l, ]; if (any(o$type == 3)) o$val[o$type == 3] else o$val[o$type == 2] - o$val[o$type == 1] }, 0)
lnN_obs <- vapply(labs, \(l) { o <- tb_obs[tb_obs$label == l, ]; if (any(o$type == 1)) o$val[o$type == 1] else o$val[o$type == 2] - o$val[o$type == 3] }, 0)
m <- cmdstanr::cmdstan_model("models/tierB_free.stan")
fit <- function(X, name) {
  d <- list(G = length(labs), J = nrow(tb_obs), P = ncol(X), obs_g = match(tb_obs$label, labs), obs_type = tb_obs$type,
            obs_val = tb_obs$val, obs_sd = tb_obs$sd, R = R, X = X, cN = mean(lnN_obs), cM = mean(lnM_obs), prior_lnN_mu = 40, prior_lnM_mu = -8)
  f <- m$sample(d, seed = 20261103, chains = 4, parallel_chains = 4, iter_warmup = 1000, iter_sampling = 2000, adapt_delta = 0.99, refresh = 0, show_messages = FALSE)
  dr <- posterior::as_draws_df(f$draws()); sm <- f$summary(c("gamma", "delta", "tau"))
  q <- function(v) c(med = median(v), lo = unname(quantile(v, .025)), hi = unname(quantile(v, .975)))
  out <- tibble(model = name, param = c("gamma (lnN)", "delta (lnM)"),
                med = c(q(dr$gamma)[1], q(dr$delta)[1]), lo = c(q(dr$gamma)[2], q(dr$delta)[2]), hi = c(q(dr$gamma)[3], q(dr$delta)[3]),
                P_gt0 = c(mean(dr$gamma > 0), mean(dr$delta > 0)), P_lt1 = c(mean(dr$gamma < 1), mean(dr$delta < 1)))
  if (ncol(X) > 0) for (p in seq_len(ncol(X))) { v <- dr[[sprintf("eta[%d]", p)]]
    out <- bind_rows(out, tibble(model = name, param = colnames(X)[p], med = median(v), lo = quantile(v, .025), hi = quantile(v, .975), P_gt0 = mean(v > 0), P_lt1 = NA)) }
  out |> mutate(rhat_max = max(f$summary()$rhat, na.rm = TRUE), divergent = sum(f$diagnostic_summary(quiet = TRUE)$num_divergent))
}
Xs <- function(...) { l <- list(...); if (!length(l)) return(matrix(0, length(labs), 0)); x <- do.call(cbind, l); x }
res <- bind_rows(
  fit(Xs(), "free: N + M"),
  fit(Xs(lnS = log(S) - mean(log(S))), "free: N + M + log S"),
  fit(Xs(soil = habitat_soil - mean(habitat_soil)), "free: N + M + soil"),
  fit(Xs(lnS = log(S) - mean(log(S)), soil = habitat_soil - mean(habitat_soil)), "free: N + M + log S + soil"))
print(res, n = 40, width = 200)
readr::write_csv(res, "sim/rev_free_exponent.csv")

# 帰無：記録数を並べ替えたときの「r–M」傾き（点推定の OLS、5,000 回）。観測値と比べる
set.seed(20261103)
lr <- log10(R); lN <- lnN_obs / log(10); lM <- lnM_obs / log(10)
obs_b <- coef(lm(I(lr - lN) ~ lM))[2]
perm <- replicate(5000, { y <- sample(lr); coef(lm(I(y - lN) ~ lM))[2] })
const <- coef(lm(I(mean(lr) - lN) ~ lM))[2]
nul <- tibble(observed_beta_ols = obs_b, constant_records_beta = const, perm_median = median(perm), perm_lo = quantile(perm, .025), perm_hi = quantile(perm, .975),
              P_perm_ge_obs = mean(perm >= obs_b), P_perm_le_obs = mean(perm <= obs_b))
print(nul); readr::write_csv(nul, "sim/rev_ratio_null.csv")
