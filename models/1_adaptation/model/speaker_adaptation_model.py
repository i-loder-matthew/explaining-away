import numpy as np
from scipy.stats import beta, uniform, bernoulli, norm, truncnorm, expon
import time, json
import sys
import os
import argparse
import copy

from threshold_model import ThresholdModel

class AdaptationModel(ThresholdModel):
  def __init__(self, config, output_path, run):
    super().__init__(config, output_path, run)
  
  def compute_likelihood(self, costs, rat_alpha, theta_alphas, theta_betas, utt_other_prior, noise_strength):
    log_lkhood = 0
    speaker_probs =  self.log_speaker_dist(costs, -1, -1, rat_alpha, theta_alphas, theta_betas, utt_other_prior, noise_strength)
    log_lkhood += np.sum(np.multiply(self.data, speaker_probs[:-1,:]))
    return log_lkhood
  
  def load_data(self):
    data = np.zeros((len(self.expressions), self.probabilities_len), dtype=np.float64)
    # exposure trials are of the form ["utterance", prob, count]
    for t in self.config["exposure_trials"]:
      data[self.expressions2idx[t[0]], self.prob2idx[t[1]]] += t[2]
    return data
  
  
  def shape_a(self, mu, nu):
    return mu * nu

  def shape_b(self, mu, nu):
    return (1-mu) * nu


  def beta_mu(self, a, b):
    return a / (a+b)

  def beta_var(self, a, b):
    return  a * b / ((a + b)**2 * (a + b + 1))

  def beta_nu(self, a, b):
    return  a + b
  
  
  def theta_mu_param_prior(self, old_val):
    width = self.config["proposal_widths"]["theta_mu"]
    if width == 0:
      return old_val
    a = (0 - old_val) / width
    b = (1 - old_val) / width
    return truncnorm(a,b,loc=old_val, scale=width).rvs()

  def theta_nu_param_prior(self, old_val, min_val):
    width = self.config["proposal_widths"]["theta_nu"]
    if width == 0:
      return old_val
    old_val = np.log(old_val)
    a = (np.log(min_val) - old_val) / width
    b = (100 - old_val) / width
    return np.exp(truncnorm(a,b,loc=old_val, scale=width).rvs())


  def rat_alpha_prior(self, old_val):
    width = self.config["proposal_widths"]["rat_alpha"]
    if width == 0:
      return old_val
    old_val = np.log(old_val)
    return np.exp(norm(old_val, width).rvs())

  def utt_other_prob_prior(self, old_val):
    if not self.config["utt_other_prob_estimate"]:
      return old_val
    width = self.config["proposal_widths"]["utt_other_prob"]
    old_val = np.log(old_val)
    return np.exp(norm(old_val, width).rvs())
  
  def init_trace(self):
      theta_mus = uniform(0,1).rvs(len(self.expressions)) 
      theta_nus = uniform(1,5).rvs(len(self.expressions)) 
      costs = uniform(0,7).rvs(len(self.expressions)) 
      rat_alpha = self.config["rat_alpha_init"]
      utt_other_prob = self.config["utt_other_prob_init"]
      noise_strength = self.config["noise_strength_init"]
      
      
      for i, utt in enumerate(self.config["utterances"]):
        if not utt["has_theta"]:
          theta_mus[i] = self.beta_mu(1,1)
          theta_nus[i] = self.beta_nu(1,1)
        else:
          if utt["mu_init"] != "random":
            theta_mus[i] = utt["mu_init"]
          if utt["nu_init"] != "random":
            theta_nus[i] = utt["nu_init"]

        if not utt["has_cost"]:
          costs[i] = 0
        else:
          if utt["cost_init"] != "random":
            costs[i] = utt["cost_init"]
            
      return np.concatenate([theta_mus, theta_nus, costs, [rat_alpha], [utt_other_prob], [noise_strength]])
  
  def compute_trans_probs(self, src_theta_mu, src_theta_nus, src_costs, src_rat_alpha, src_utt_other_prob, 
                          tgt_theta_mu, tgt_theta_nus, tgt_costs, tgt_rat_alpha, tgt_utt_other_prob):
      log_prob = 0
      theta_mu_width = self.config["proposal_widths"]["theta_mu"]
      theta_nu_width = self.config["proposal_widths"]["theta_nu"]
      cost_width = self.config["proposal_widths"]["cost"]
      rat_alpha_width = self.config["proposal_widths"]["rat_alpha"]
      utt_other_width = self.config["proposal_widths"]["utt_other_prob"]
      for i, utt in enumerate(self.config["utterances"]):
        if utt["has_theta"] and utt["prior"]["mu_sd"] > 0 and theta_mu_width > 0:
          src = src_theta_mu[i]
          tgt = tgt_theta_mu[i]
          a = (0 - src) / theta_mu_width
          b = (1 - src) / theta_mu_width
          log_prob += truncnorm(a,b, loc=src, scale=theta_mu_width).logpdf(tgt)
          
          src = np.log(src_theta_nus[i])
          tgt = np.log(tgt_theta_nus[i])
          a = (np.log(utt["nu_init"]) - src) / theta_nu_width
          b = (100 - src) / theta_nu_width
          log_prob += truncnorm(a,b, loc=src, scale=theta_nu_width).logpdf(tgt)
        if utt["has_cost"] and "copy_cost" not in utt and utt["prior"]["cost_sd"] > 0 and cost_width > 0:
          src = np.log(src_costs[i])
          tgt = np.log(tgt_costs[i])
          log_prob += norm(src, cost_width).logpdf(tgt)
      
      if (self.config["rat_alpha_estimate"]):
          src = np.log(src_rat_alpha)
          tgt = np.log(tgt_rat_alpha)
          log_prob += norm(src, rat_alpha_width).logpdf(tgt)
      
      if self.config["utt_other_prob_estimate"]:
        src = np.log(src_utt_other_prob)
        tgt = np.log(tgt_utt_other_prob)
        log_prob += norm(src, utt_other_width).logpdf(tgt)
        

      return log_prob
  
  
  
  
  def compute_prior(self, theta_mus, theta_nus, theta_alphas, theta_betas, costs, rat_alpha, utt_other_prob):
    params = np.concatenate((theta_alphas, theta_betas, costs))
    if np.any(params > 50) or np.any(params < 0):
      return float("-inf")
    
    log_prior = 0
    for i, utt in enumerate(self.config["utterances"]):
      if utt["has_theta"] and utt["prior"]["mu_sd"] > 0:
        log_prior += norm(utt["prior"]["mu_mu"], utt["prior"]["mu_sd"]).logpdf(theta_mus[i])
        log_prior += expon(loc=utt["nu_init"]-0.00000001, scale=self.config["theta_nu_scale"]).logpdf(theta_nus[i])
      
      if utt["has_cost"] and "copy_cost" not in utt and utt["prior"]["cost_sd"] > 0:
        log_prior += norm(np.log(utt["prior"]["cost_mu"]), utt["prior"]["cost_sd"]).logpdf(np.log(costs[i]))
    
    if (self.config["rat_alpha_estimate"]):
      log_prior += norm(self.config["rat_alpha_prior"]["rat_alpha_mu"], 
                        self.config["rat_alpha_prior"]["rat_alpha_sd"]).logpdf(rat_alpha)

    if self.config["utt_other_prob_estimate"]:
      log_prior += norm(np.log(self.config["utt_other_prob_prior"]["utt_other_prob_mu"]), 
                        self.config["utt_other_prob_prior"]["utt_other_prob_sd"]).logpdf(np.log(utt_other_prob))
      
    
    return log_prior
  
  
  def run_mcmc(self):
      acceptance = 0
      samples = []
      
      params = self.init_trace()
      old_theta_mus = params[0:len(self.expressions)]
      old_theta_nus = params[len(self.expressions):len(self.expressions)*2]
      old_theta_alphas = [self.shape_a(old_theta_mus[i], old_theta_nus[i]) for i in range(len(self.expressions))]
      old_theta_betas = [self.shape_b(old_theta_mus[i], old_theta_nus[i]) for i in range(len(self.expressions))]
      old_costs = params[len(self.expressions)*2:len(self.expressions)*3]
      old_rat_alpha = params[len(self.expressions)*3]
      old_utt_other_prob = params[len(self.expressions)*3 + 1]
      old_noise_strength = params[len(self.expressions)*3 + 2]
      utt_other_prob = old_utt_other_prob
      noise_strength = old_noise_strength
      
      prior = self.compute_prior(old_theta_mus, old_theta_nus, old_theta_alphas, old_theta_betas, old_costs, old_rat_alpha, old_utt_other_prob) 
      old_likelihood = self.compute_likelihood(old_costs, old_rat_alpha, old_theta_alphas, old_theta_betas, old_utt_other_prob, old_noise_strength) + prior
      sample = self.make_sample(old_costs, old_theta_alphas, old_theta_betas, old_rat_alpha, old_utt_other_prob, old_noise_strength)
            
      iterations = self.config["iterations"]
      burn_in = self.config["burn_in"] if "burn_in" in self.config else 0
      
      
      log_file_name = os.path.join(self.output_path, "run{}.log".format(self.run))
      output_file_name = os.path.join(self.output_path, "run{}_output.json".format(self.run))
      
      log_file = open(log_file_name, "w")
      
      for it in range(iterations):
        if it > 0 and it % 100 == 0:
          print("Iteration: {} ".format(it), file=log_file)
          print("Acceptance rate: {}".format(acceptance * 1.0 / it), file=log_file)
          log_file.flush()
        
        
        theta_alphas = copy.copy(old_theta_alphas)
        theta_betas = copy.copy(old_theta_betas)
        theta_mus = copy.copy(old_theta_mus)
        theta_nus = copy.copy(old_theta_nus)
        costs = copy.copy(old_costs)
        
        
        for i, utt in enumerate(self.config["utterances"]):
          if utt["has_theta"] and utt["prior"]["mu_sd"] > 0:
            theta_mus[i] = self.theta_mu_param_prior(old_theta_mus[i])
            theta_nus[i] = self.theta_nu_param_prior(old_theta_nus[i], utt["nu_init"])
            theta_alphas[i] = self.shape_a(theta_mus[i], theta_nus[i])
            theta_betas[i] = self.shape_b(theta_mus[i], theta_nus[i])
          if utt["has_cost"] and "copy_cost" not in utt and utt["prior"]["cost_sd"] > 0:
            costs[i] = self.cost_prior(old_costs[i])
        for i, utt in enumerate(self.config["utterances"]):
          if utt["has_cost"] and "copy_cost" in utt:
            costs[i] = costs[self.expressions2idx[utt["copy_cost"]]]
        
        if self.config["rat_alpha_estimate"]:
          rat_alpha = self.rat_alpha_prior(old_rat_alpha)
        else:
          rat_alpha = old_rat_alpha
                
        if self.config["utt_other_prob_estimate"]:
          utt_other_prob = self.utt_other_prob_prior(old_utt_other_prob)
        else:
          utt_other_prob = old_utt_other_prob
        
        prior = self.compute_prior(theta_mus, theta_nus, theta_alphas, theta_betas, costs, rat_alpha, utt_other_prob)
        new_likelihood = self.compute_likelihood(costs, rat_alpha, theta_alphas, theta_betas, utt_other_prob, noise_strength) + prior
        accept = new_likelihood > old_likelihood
        if not accept:
          bwd_prob = self.compute_trans_probs(theta_mus, theta_nus, costs, rat_alpha, utt_other_prob,
                                         old_theta_mus, old_theta_nus, old_costs, old_rat_alpha, old_utt_other_prob)
          fwd_prob = self.compute_trans_probs(old_theta_mus, old_theta_nus, old_costs, old_rat_alpha, old_utt_other_prob,
                                         theta_mus, theta_nus, costs, rat_alpha, utt_other_prob)   
          likelihood_ratio = new_likelihood - old_likelihood - fwd_prob + bwd_prob
          u = np.log(uniform(0,1).rvs())
          if u < likelihood_ratio:
            accept = True
        
        if accept:
          old_likelihood = new_likelihood
          sample = self.make_sample(costs, theta_alphas, theta_betas, rat_alpha, utt_other_prob, noise_strength)
          acceptance += 1
          old_costs = costs
          old_theta_alphas = theta_alphas
          old_theta_betas = theta_betas
          old_theta_mus = theta_mus
          old_theta_nus = theta_nus
          old_rat_alpha = rat_alpha
          old_utt_other_prob = utt_other_prob
        
        if it > burn_in and it % 10 == 0:
          samples.append(sample)
          if len(samples) % 1000 == 0:
            json.dump(samples, open(output_file_name, "w"))
  
        if it % 20000 == 0: 
          self.speaker_matrix_cache.clear()
          self.theta_prior_cache.clear()
    



def main():
  parser = argparse.ArgumentParser()
  parser.add_argument("--out_dir", required=True)
  parser.add_argument("--run", required=True)
  args = parser.parse_args()
  
  out_dir = args.out_dir
  config_file_path = os.path.join(out_dir, "config.json")
  config = json.load(open(config_file_path, "r"))
  
  model = AdaptationModel(config, out_dir, args.run)
  model.run_mcmc()

        
if __name__ == '__main__':
  main()
