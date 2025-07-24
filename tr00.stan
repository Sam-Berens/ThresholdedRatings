data {
  int<lower=1> N;                     // participants
  int<lower=1> K;                     // options

  // Stage 1: relevance selections
  array[N, K] int<lower=0,upper=1> sel;     // 1 = selected, 0 = not

  // Stage 2: importance ratings, only for selected items
  // We'll pass the rated observations in long form to avoid missing data hassles
  int<lower=0> N_rate;                // number of (i,k) pairs that have ratings
  array[N_rate] int<lower=1,upper=N> i_rate;
  array[N_rate] int<lower=1,upper=K> k_rate;
  array[N_rate] int<lower=1,upper=7> rating;
}

parameters {
  // Population option effects
  vector[K] theta;

  // Participant deviations (non-centered)
  matrix[N, K] z_thetaPrime;
  real<lower=0> gamma;

  // Participant thresholds for selection
  vector[N] z_theta_bar;
  real mu_bar;
  real<lower=0> sigma_bar;

  // Ordinal (importance) model
  real<lower=0> lambda;               // slope linking latent importance to rating
  ordered[6] cutpoints;               // 6 cutpoints for 7 categories

  // (Optional) you could add residual SD for ratings if you wanted a probit-like model
}

transformed parameters {
  matrix[N, K] thetaPrime;            // individual-by-option latent importance
  vector[N] theta_bar;                // individual thresholds

  thetaPrime = rep_matrix(theta', N) + gamma * z_thetaPrime;
  theta_bar  = mu_bar + sigma_bar * z_theta_bar;
}

model {
  // Priors – tweak as needed
  theta        ~ normal(0, 1.5);
  gamma        ~ normal(0, 1) T[0,];            // half-normal
  mu_bar       ~ normal(0, 1.5);
  sigma_bar    ~ normal(0, 1) T[0,];            // half-normal

  to_vector(z_thetaPrime) ~ normal(0, 1);
  z_theta_bar             ~ normal(0, 1);

  lambda       ~ normal(1, 1) T[0,];            // positive slope
  cutpoints    ~ normal(0, 2);                  // weakly-informative; must be ordered

  // Likelihood: Stage 1
  for (n in 1:N) {
    for (k in 1:K) {
      sel[n, k] ~ bernoulli_logit(thetaPrime[n, k] - theta_bar[n]);
    }
  }

  // Likelihood: Stage 2 (only for selected items)
  // Use thetaPrime directly (or subtract theta_bar if you prefer that interpretation)
  for (m in 1:N_rate) {
    int n = i_rate[m];
    int k = k_rate[m];
    rating[m] ~ ordered_logistic(lambda * thetaPrime[n, k], cutpoints);
  }
}

generated quantities {
  // Posterior predictive
  array[N, K] int sel_rep;
  array[N_rate] int rating_rep;

  for (n in 1:N) {
    for (k in 1:K) {
      sel_rep[n, k] = bernoulli_logit_rng(thetaPrime[n, k] - theta_bar[n]);
    }
  }

  for (m in 1:N_rate) {
    int n = i_rate[m];
    int k = k_rate[m];
    rating_rep[m] = ordered_logistic_rng(lambda * thetaPrime[n, k], cutpoints);
  }
}
