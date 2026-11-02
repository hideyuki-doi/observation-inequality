# PREREG 用：Tier B モデルのパラメータ回復テスト（模擬データのみ。実データの r は見ない）
library(cmdstanr)
set.seed(20261103)
m <- cmdstan_model("models/tierB_eiv.stan")
sim_one <- function(b_true, tau_true, G = 10, sdo = log(10) / 1.96) {
  lnM <- runif(G, log(1e-7), log(3)); lnN <- rnorm(G, log(1e18), 2)
  lnM_c <- mean(lnM)
  R <- rpois(G, exp(lnN + -33 + b_true * (lnM - lnM_c) + rnorm(G, 0, tau_true)))
  # 半分のグループは N と B、残りは B と m を観測（Bar-On 型）
  obs <- do.call(rbind, lapply(1:G, \(g) if (g %% 2) data.frame(g, t = c(1, 2), v = c(lnN[g], lnN[g] + lnM[g])) else
    data.frame(g, t = c(2, 3), v = c(lnN[g] + lnM[g], lnM[g]))))
  obs$v <- obs$v + rnorm(nrow(obs), 0, sdo)
  d <- list(G = G, K = 1, J = nrow(obs), obs_g = obs$g, obs_type = obs$t, obs_val = obs$v, obs_sd = rep(sdo, nrow(obs)),
            R = matrix(pmax(R, 1), G, 1), lnM_c = lnM_c, prior_lnN_mu = 40, prior_lnM_mu = -8)
  f <- m$sample(d, seed = 20261103, chains = 4, parallel_chains = 4, refresh = 0, show_messages = FALSE,
                adapt_delta = 0.99, iter_warmup = 1000, iter_sampling = 1000)
  s <- f$summary(c("b[1]", "R2[1]"), ~quantile(.x, c(.025, .5, .975)))
  dg <- f$diagnostic_summary(quiet = TRUE)
  data.frame(b_true, tau_true, b_lo = s[[2]][1], b_med = s[[3]][1], b_hi = s[[4]][1], R2_med = s[[3]][2],
             divergent = sum(dg$num_divergent), rhat_max = max(f$summary()$rhat, na.rm = TRUE))
}
res <- do.call(rbind, lapply(c(0.67, 1.0, 1.5), \(b) do.call(rbind, lapply(c(0.5, 2), \(t) do.call(rbind, replicate(2, sim_one(b, t), simplify = FALSE))))))
print(res, digits = 3)
write.csv(res, "models/recovery_test_tierB.csv", row.names = FALSE)
