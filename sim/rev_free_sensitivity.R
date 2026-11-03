# 改訂（Reviewers 3, 5）：自由係数モデルの事前分布の感度、センサスの換算の代替値、事後予測チェック
source("sim/explore_common.R")
tar_load(c(tb_obs, tb_R, p5_S))
labs <- sort(unique(tb_obs$label)); R <- tb_R$all[match(labs, tb_R$label)]; S <- p5_S[labs]; S["jellyfish"] <- 297
src0 <- readLines("models/tierB_free.stan")
run <- function(obs, name, prior_sd = 2) {
  lnM_obs <- vapply(labs, \(l) { o <- obs[obs$label == l, ]; if (any(o$type == 3)) o$val[o$type == 3] else o$val[o$type == 2] - o$val[o$type == 1] }, 0)
  lnN_obs <- vapply(labs, \(l) { o <- obs[obs$label == l, ]; if (any(o$type == 1)) o$val[o$type == 1] else o$val[o$type == 2] - o$val[o$type == 3] }, 0)
  src <- sub("gamma ~ normal(0, 2); delta ~ normal(0, 2); eta ~ normal(0, 2);",
             sprintf("gamma ~ normal(0, %s); delta ~ normal(0, %s); eta ~ normal(0, %s);", prior_sd, prior_sd, prior_sd), src0, fixed = TRUE)
  src <- sub("generated quantities {", "generated quantities {\n  vector[G] lnR_rep;\n  for (g in 1:G) lnR_rep[g] = normal_rng(a + gamma * (lnN[g] - cN) + delta * (lnM[g] - cM) + X[g] * eta, sqrt(square(tau) + inv(R[g])));", src, fixed = TRUE)
  m <- cmdstanr::cmdstan_model(cmdstanr::write_stan_file(src))
  dd <- list(G = length(labs), J = nrow(obs), P = 1, obs_g = match(obs$label, labs), obs_type = obs$type, obs_val = obs$val, obs_sd = obs$sd,
             R = R, X = matrix(log(S) - mean(log(S)), ncol = 1), cN = mean(lnN_obs), cM = mean(lnM_obs), prior_lnN_mu = 40, prior_lnM_mu = -8)
  f <- m$sample(dd, seed = 20261103, chains = 4, parallel_chains = 4, iter_warmup = 1000, iter_sampling = 2000, adapt_delta = 0.99, refresh = 0, show_messages = FALSE)
  dr <- posterior::as_draws_df(f$draws()); rep <- as.matrix(dr[, grep("^lnR_rep", names(dr))])
  cover <- mean(sapply(seq_along(labs), \(g) { q <- quantile(rep[, g], c(.025, .975)); log(R[g]) >= q[1] & log(R[g]) <= q[2] }))
  tibble(analysis = name, param = c("gamma (lnN)", "delta (lnM)", "lnS"), med = c(median(dr$gamma), median(dr$delta), median(dr$`eta[1]`)),
         lo = c(quantile(dr$gamma, .025), quantile(dr$delta, .025), quantile(dr$`eta[1]`, .025)),
         hi = c(quantile(dr$gamma, .975), quantile(dr$delta, .975), quantile(dr$`eta[1]`, .975)),
         P_gt0 = c(mean(dr$gamma > 0), mean(dr$delta > 0), mean(dr$`eta[1]` > 0)), ppc_95_coverage = cover)
}
mod <- function(o, lab, type, add) { i <- o$label == lab & o$type == type; o$val[i] <- o$val[i] + add; o }
res <- bind_rows(
  run(tb_obs, "main (priors N(0,2))"),
  run(tb_obs, "wider priors N(0,5)", prior_sd = 5),
  run(mod(mod(tb_obs, "jellyfish", 2, log(50)), "jellyfish", 3, log(50)), "jellyfish mass ×50 (gelatinous C/wet)"),
  run(mod(tb_obs, "soil_nematodes", 2, log(0.15 / 0.105)), "nematode C/fresh 0.105"),
  run(mod(tb_obs, "krill", 1, log(2.4e14 / 7.8e14)), "krill N, unadjusted nets"),
  # S5b（事前登録、初版で未実施）：Rosenberg のコードの再実行によるトビムシ N = 3.45e18、B = 17.69 Mt 乾重（乾重/湿重 0.32）
  run({ o <- tb_obs; o$val[o$label == "springtails" & o$type == 1] <- log(3.45e18); o$val[o$label == "springtails" & o$type == 2] <- log(17.69e12 / 0.32); o },
      "S5b springtails from Rosenberg re-run"))
print(res, n = 30, width = 200); readr::write_csv(res, "sim/rev_free_sensitivity.csv")
