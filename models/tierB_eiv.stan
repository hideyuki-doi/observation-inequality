// Tier B：errors-in-variables のスケーリングモデル（自然対数）
// 各グループ g の潜在値：lnN[g]（個体数）、lnM[g]（1個体の湿重量 g）
// センサス観測：lnN, lnB(= lnN + lnM), lnm(= lnM) のうち2つ（obs_type 1=N, 2=B, 3=m）
// 記録数：lnR[g,k] ~ N(lnN + a[k] + b[k] * (lnM - lnM_c), sqrt(tau[k]^2 + 1/R))
//   （記録数は 10^3 以上なので Poisson を対数正規で近似。1/R はポアソン分散のデルタ法）
data {
  int<lower=1> G;
  int<lower=1> K;
  int<lower=1> J;
  array[J] int<lower=1, upper=G> obs_g;
  array[J] int<lower=1, upper=3> obs_type;
  vector[J] obs_val;
  vector<lower=0>[J] obs_sd;
  matrix<lower=1>[G, K] R;        // 記録数（0 のグループ×種類は事前登録の規則で除外）
  real lnM_c;
  real prior_lnN_mu;
  real prior_lnM_mu;
}
parameters {
  vector[G] lnN;
  vector[G] lnM;
  vector[K] a;
  vector[K] b;
  vector<lower=0>[K] tau;
}
model {
  lnN ~ normal(prior_lnN_mu, 25);
  lnM ~ normal(prior_lnM_mu, 25);
  a ~ normal(-25, 10);
  b ~ normal(0, 2);
  tau ~ normal(0, 2);
  for (j in 1:J) {
    real mu = obs_type[j] == 1 ? lnN[obs_g[j]] : (obs_type[j] == 2 ? lnN[obs_g[j]] + lnM[obs_g[j]] : lnM[obs_g[j]]);
    obs_val[j] ~ normal(mu, obs_sd[j]);
  }
  for (k in 1:K)
    log(R[, k]) ~ normal(lnN + a[k] + b[k] * (lnM - lnM_c), sqrt(square(tau[k]) + inv(R[, k])));
}
generated quantities {
  vector[K] R2;
  for (k in 1:K) {
    real vf = variance(a[k] + b[k] * (lnM - lnM_c));
    R2[k] = vf / (vf + square(tau[k]));
  }
}
