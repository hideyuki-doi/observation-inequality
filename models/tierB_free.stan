// 改訂：記録数の自由係数モデル（errors-in-variables）
// ln R_g ~ Normal(a + gamma * (lnN_g - cN) + delta * (lnM_g - cM) + X_g * eta, sqrt(tau^2 + 1/R_g))
// gamma = 1, delta = beta が「1 個体あたり記録数 r ∝ M^beta」のモデルに対応。gamma が 0 なら記録数は個体数と無関係
data {
  int<lower=1> G; int<lower=1> J; int<lower=0> P;
  array[J] int<lower=1, upper=G> obs_g; array[J] int<lower=1, upper=3> obs_type;
  vector[J] obs_val; vector<lower=0>[J] obs_sd;
  vector<lower=1>[G] R; matrix[G, P] X;
  real cN; real cM; real prior_lnN_mu; real prior_lnM_mu;
}
parameters {
  vector[G] lnN; vector[G] lnM; real a; real gamma; real delta; vector[P] eta; real<lower=0> tau;
}
model {
  lnN ~ normal(prior_lnN_mu, 25); lnM ~ normal(prior_lnM_mu, 25);
  a ~ normal(13, 10); gamma ~ normal(0, 2); delta ~ normal(0, 2); eta ~ normal(0, 2); tau ~ normal(0, 2);
  for (j in 1:J) {
    real mu = obs_type[j] == 1 ? lnN[obs_g[j]] : (obs_type[j] == 2 ? lnN[obs_g[j]] + lnM[obs_g[j]] : lnM[obs_g[j]]);
    obs_val[j] ~ normal(mu, obs_sd[j]);
  }
  log(R) ~ normal(a + gamma * (lnN - cN) + delta * (lnM - cM) + X * eta, sqrt(square(tau) + inv(R)));
}
generated quantities {
  real beta_implied = delta - (gamma - 1) * 0;  // r = R/N: ln r = a + (gamma-1) lnN + delta lnM（N と M が独立に動く場合の M の効果）
}
