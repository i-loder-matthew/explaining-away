import numpy as np
from scipy.stats import beta, uniform, bernoulli, norm
import time, json
import sys
import os
import argparse
import copy



class ThresholdModel:

  def __init__(self, config, output_path, run, subjectid=None):
    self.config = config
    self.run = run
    self.output_path = output_path
    self.subjectid = subjectid
        
    # Intialize constants
    
    self.probabilities = list(range(0,101,5))
    self.prob2idx = {p:i for i,p in enumerate(self.probabilities )}
    self.probabilities_len = len(self.probabilities )
    self.lit_listener_shp = [self.probabilities_len, self.probabilities_len]  
    
    # Intialize expression
    self.expressions = [utt["form"] for utt in config["utterances"]]
    self.expressions2idx = {utt["form"]:i for i,utt in enumerate(config["utterances"])}
    
    
    # Initialize literal listener matrices
    self.threshold_listener = self.init_threshold_listener()
    self.threshold_listener_log = np.log(self.threshold_listener)
    
    self.threshold_listener_neg = np.transpose(self.init_threshold_listener())
    self.threshold_listener_neg_log = np.log(self.threshold_listener_neg)
        
    self.uniform_listener = self.init_uniform_listener()
    self.uniform_listener_log = np.log(self.uniform_listener)
    
    
    # load and prepare data
    
    self.data = self.load_data()
    
    # initialize caches
    self.speaker_matrix_cache = {}
    self.theta_prior_cache = {}
    
    
    
  # RSA model and likelihood computation

  def init_threshold_listener(self):
    listener_matrix = np.tril(np.full(self.lit_listener_shp, 1.0, dtype=np.float64), 0) 
    col_sums = np.sum(listener_matrix, axis=0)
    return listener_matrix / col_sums
  
  def init_uniform_listener(self):
    listener_matrix = np.full(self.lit_listener_shp, 1.0, dtype=np.float64) 
    col_sums = np.sum(listener_matrix, axis=0)
    return listener_matrix / col_sums

  def log_literal_listener(self, has_thetas = True, theta_alpha = 1, theta_beta = 1, is_neg = False):
    if self.config["theta_marginalization"] == "speaker":
      if has_thetas:
        if is_neg:
          return self.threshold_listener_neg_log
        else:
          return self.threshold_listener_log
      else:
        return self.uniform_listener_log
    else:
      return np.log(self.literal_listener(has_thetas, theta_alpha, theta_beta, is_neg))

  def literal_listener(self, has_thetas = True, theta_alpha = 1, theta_beta = 1, is_neg = False):
    if self.config["theta_marginalization"] == "speaker":  
      if has_thetas:
        if is_neg:
          return self.threshold_listener_neg
        else:
          return self.threshold_listener
      else:
        return self.uniform_listener
    else:
      p_theta = self.theta_prior(theta_alpha, theta_beta, has_thetas, is_neg)
      listener_matrix = None
      if has_thetas:
        if is_neg:
          listener_matrix = self.threshold_listener_neg
        else:
         listener_matrix = self.threshold_listener
      else:
        listener_matrix = self.uniform_listener
      listener_matrix = np.reshape(np.dot(listener_matrix, p_theta), (self.probabilities_len,))
      listener_matrix = listener_matrix / np.sum(listener_matrix)
      #listener_matrix = 0.1 * self.uniform_listener[0] + 0.9 * listener_matrix
      return listener_matrix
  
  def speaker_matrix(self, utt_cost, utt_idx, theta_alpha, theta_beta, expr_idx1, expr_idx2, rat_alpha):
    key_tuple = (utt_cost, utt_idx, theta_alpha, theta_beta, expr_idx1, expr_idx2, rat_alpha) 
    if key_tuple not in self.speaker_matrix_cache:
      if self.config["condition_encoding"] == "cost":
        utt_cost = utt_cost if utt_idx != expr_idx1 and utt_idx != expr_idx2 else 1
      has_thetas = self.config["utterances"][utt_idx]["has_theta"]
      is_neg = "is_neg" in self.config["utterances"][utt_idx] and self.config["utterances"][utt_idx]["is_neg"]
      listener_matrix = self.log_literal_listener(has_thetas, theta_alpha, theta_beta, is_neg)
      costs = self.cost_matrix(utt_cost)
      self.speaker_matrix_cache[key_tuple] = np.exp(rat_alpha * (listener_matrix - costs))
    return self.speaker_matrix_cache[key_tuple]
    
  def theta_prior(self, a, b, has_theta = True, is_neg = False):
    key_tuple = (a, b, has_theta, is_neg)
    if key_tuple not in self.theta_prior_cache:
      distr = beta(a,b)
      if not has_theta:
        probs = np.ones((self.probabilities_len, ))
      else:
        if is_neg:
          ticks =  np.arange(0.05, 1.06, 0.05)
          ticks2 = np.arange(0.0, 1.01, 0.05)
        else: 
          ticks = np.arange(-0.05, 1.0, 0.05)
          ticks2 = np.arange(0.0, 1.01, 0.05)
        probs = distr.cdf(ticks) - distr.cdf(ticks2)
      probs = probs / np.sum(probs)
      self.theta_prior_cache[key_tuple] = np.reshape(probs, (self.probabilities_len, 1))
    return self.theta_prior_cache[key_tuple]
  
  def cost_matrix(self, utt_cost):
    if self.config["theta_marginalization"] == "speaker":
      return np.full(self.lit_listener_shp, utt_cost)
    else:
      return np.full((self.probabilities_len, ), utt_cost)
      
  def log_speaker_dist(self, utt_costs, expr_idx1, expr_idx2, rat_alpha, theta_alphas, theta_betas, utt_other_prob, noise_strength):
    speaker_distr = np.zeros((3, self.probabilities_len))
    if expr_idx1 < 0:
      speaker_distr = np.zeros((len(self.expressions) + 1, self.probabilities_len))
    
    expected_speaker_matrix = np.zeros((len(self.expressions), self.probabilities_len))
    
    for i in range(len(self.expressions)):
      utt_cost = utt_costs[i]
      if self.config["theta_marginalization"] == "speaker":
        is_neg = "is_neg" in self.config["utterances"][i] and self.config["utterances"][i]["is_neg"]
        has_thetas = self.config["utterances"][i]["has_theta"]
        p_theta = self.theta_prior(theta_alphas[i], theta_betas[i], has_thetas, is_neg)
        speaker_row = self.speaker_matrix(utt_cost, i, 1, 1, expr_idx1, expr_idx2, rat_alpha)
        expected_speaker_matrix[i,:] = np.reshape(np.dot(speaker_row, p_theta), (self.probabilities_len,))
    
    for i in range(len(self.expressions)):
      utt_cost = utt_costs[i]
      idx = i
      if expr_idx1 >= 0 and expr_idx2 >= 0:
        idx = 0 if i == expr_idx1 else (1 if i == expr_idx2 else 2)
      is_neg = "is_neg" in self.config["utterances"][i] and self.config["utterances"][i]["is_neg"]
      has_thetas = self.config["utterances"][i]["has_theta"]
      p_theta = self.theta_prior(theta_alphas[i], theta_betas[i], has_thetas, is_neg)
      speaker_row = self.speaker_matrix(utt_cost, i, 1, 1, expr_idx1, expr_idx2, rat_alpha)
      normalization_rows = [j for j in range(len(self.expressions)) if j != i]
      normalization_term = np.sum(expected_speaker_matrix[normalization_rows, :], axis = 0).reshape((self.probabilities_len,1)) + utt_other_prob
      speaker_row = speaker_row / (normalization_term + speaker_row)
      speaker_distr[idx, :] += np.reshape(np.dot(speaker_row, p_theta), (self.probabilities_len,))
    
    speaker_distr[-1, :] += utt_other_prob / (np.sum(expected_speaker_matrix, axis = 0).reshape((self.probabilities_len,)) + utt_other_prob)
    speaker_row_sums = np.sum(speaker_distr, axis=0)
    
    n_utt = speaker_distr.shape[0]
    return np.log((1-noise_strength) * (speaker_distr / speaker_row_sums) + (noise_strength / n_utt))
  
  def compute_likelihood(self, costs, rat_alpha, theta_alphas, theta_betas, utt_other_prob, noise_strength):
    log_lkhood = 0
    for expr_1, expr_2 in self.data:
      speaker_probs =  self.log_speaker_dist(costs, self.expressions2idx[expr_1], self.expressions2idx[expr_2], rat_alpha, theta_alphas, theta_betas, utt_other_prob, noise_strength)
      log_lkhood += np.sum(np.multiply(self.data[(expr_1, expr_2)], speaker_probs))
    return log_lkhood

  
  # Data loading and pre-processing
  def load_data(self):
    raw_data = json.load(open(self.config["data_path"], "r"))
    count_arrays = dict()
    workerids = dict()
    for d in raw_data["obs"]:
      if "exclude_conditions" in self.config and d["pair"] in self.config["exclude_conditions"]:
        continue
      expr_pair = (d["modal1"], d["modal2"])
      if expr_pair not in count_arrays:
        count_arrays[expr_pair] = np.zeros((3, self.probabilities_len))
        if "worker_samples" in self.config:
          workerids[expr_pair] = np.random.choice(range(20), self.config["worker_samples"])
      
      if "worker_samples" in self.config and d["workerid"] not in workerids[expr_pair]:
        continue
        
      is_subject_estimate_condition = "subject_estimate_condition" in self.config and d["pair"] == self.config["subject_estimate_condition"]  
      if is_subject_estimate_condition and d["workerid"] != self.subjectid:
        continue
      col_idx = self.prob2idx[d["percentage_blue"]]
      row_idx = 2 if d["modal"] == "other" else 0 if d["modal"] == d["modal1"] else 1
      increment = 200 if is_subject_estimate_condition else 1
      count_arrays[expr_pair][row_idx, col_idx] += increment
    return count_arrays
  

  #MCMC functions
  def theta_param_prior(self, old_val):
    old_val = np.log(old_val)
    width = self.config["proposal_widths"]["theta"]
    return np.exp(norm(old_val, width).rvs())


  def cost_prior(self, old_val):
    old_val = np.log(old_val)
    width = self.config["proposal_widths"]["cost"]
    return np.exp(norm(old_val, width).rvs())  

  def rat_alpha_prior(self, old_val):
    width = self.config["proposal_widths"]["rat_alpha"]
    a = max(0, old_val - width)
    b = min(6, old_val + width)
    b = max(0, b - a)
    return uniform(a, b).rvs()
  

  def utt_other_prob_prior(self, old_val):
    width = self.config["proposal_widths"]["utt_other_prob"]
    old_val = np.log(old_val)
    return np.exp(norm(old_val, width).rvs())

  def noise_strength_prior(self, old_val):
    width = self.config["proposal_widths"]["noise_strength"]
    a = max(0, old_val - width)
    b = min(.5, old_val + width)
    b = max(0, b - a)
    return uniform(a, b).rvs()
    
  
  def compute_prior(self,theta_alphas, theta_betas, costs):
    params = np.concatenate((theta_alphas, theta_betas, costs))
    if np.any(params > 15):
      return float("-inf")
    return 0;

  def compute_trans_probs(self, src_theta_alphas, src_theta_betas, src_costs, 
                          tgt_theta_alphas, tgt_theta_betas, tgt_costs):
      log_prob = 0
      theta_width = self.config["proposal_widths"]["theta"]
      cost_width = self.config["proposal_widths"]["cost"]
      for i, utt in enumerate(self.config["utterances"]):
        if utt["has_theta"]:
          src = np.log(src_theta_alphas[i])
          tgt = np.log(tgt_theta_alphas[i])
          log_prob += norm(src, theta_width).logpdf(tgt)
          
          src = np.log(src_theta_betas[i])
          tgt = np.log(tgt_theta_betas[i])
          log_prob += norm(src, theta_width).logpdf(tgt)
        if utt["has_cost"] and "copy_cost" not in utt:
          src = np.log(src_costs[i])
          tgt = np.log(tgt_costs[i])
          log_prob += norm(src, cost_width).logpdf(tgt)
      return log_prob
    
  def make_sample(self, costs, theta_alphas, theta_betas, rat_alpha, utt_other_prob, noise_strength):
      sample = {
        "rat_alpha": rat_alpha,
        "utt_other_prob": utt_other_prob,
        "noise_strength": noise_strength
      }
      for i, utt in enumerate(self.config["utterances"]):
        sample["alpha_" + utt["form"]] = theta_alphas[i]
        sample["beta_" + utt["form"]] = theta_betas[i]
        sample["cost_" + utt["form"]] = costs[i]
      return sample
    
    
  def init_trace(self):
      theta_alphas = uniform(0,7).rvs(len(self.expressions)) 
      theta_betas = uniform(0,7).rvs(len(self.expressions)) 
      costs = uniform(0,7).rvs(len(self.expressions)) 
      rat_alpha = self.config["rat_alpha_init"]
      utt_other_prob = self.config["utt_other_prob_init"]
      old_noise_strength = self.config["noise_strength_init"]
      
      for i, utt in enumerate(self.config["utterances"]):
        if not utt["has_theta"]:
          theta_alphas[i] = 1
          theta_betas[i] = 1
        else:
          if utt["alpha_init"] != "random":
            theta_alphas[i] = utt["alpha_init"]
          if utt["beta_init"] != "random":
            theta_betas[i] = utt["beta_init"]

        if not utt["has_cost"]:
          costs[i] = 0
        else:
          if utt["cost_init"] != "random":
            costs[i] = utt["cost_init"]
      
      for i, utt in enumerate(self.config["utterances"]):
          if utt["has_cost"] and "copy_cost" in utt:
            costs[i] = costs[self.expressions2idx[utt["copy_cost"]]]
            
      return np.concatenate([theta_alphas, theta_betas, costs, [rat_alpha], [utt_other_prob], [old_noise_strength]])
    
    
  def run_mcmc(self):
      acceptance = 0
      samples = []
      
      params = self.init_trace()
      old_theta_alphas = params[0:len(self.expressions)]
      old_theta_betas = params[len(self.expressions):len(self.expressions)*2]
      old_costs = params[len(self.expressions)*2:len(self.expressions)*3]
      old_rat_alpha = params[len(self.expressions)*3]
      old_utt_other_prob = params[len(self.expressions)*3 + 1]
      old_noise_strength = params[len(self.expressions)*3 + 2]
      print(old_noise_strength)
      
      prior = self.compute_prior(old_theta_alphas, old_theta_betas, old_costs) 
      old_likelihood = self.compute_likelihood(old_costs, old_rat_alpha, old_theta_alphas, old_theta_betas, old_utt_other_prob, old_noise_strength) + prior
      sample = self.make_sample(old_costs, old_theta_alphas, old_theta_betas, old_rat_alpha, old_utt_other_prob, old_noise_strength)
            
      iterations = self.config["iterations"]
      burn_in = self.config["burn_in"] if "burn_in" in self.config else 0
      
      subjectid_suffix = "_subject{}".format(self.subjectid) if self.subjectid is not None else ""
      
      log_file_name = os.path.join(self.output_path, "run{}{}.log".format(self.run, subjectid_suffix))
      output_file_name = os.path.join(self.output_path, "run{}{}_output.json".format(self.run, subjectid_suffix))
      
      log_file = open(log_file_name, "w")
      
      for it in range(iterations):
        if it > 0 and it % 100 == 0:
          print("Iteration: {} ".format(it), file=log_file)
          print("Acceptance rate: {}".format(acceptance * 1.0 / it), file=log_file)
          print("Log likelihood: {}".format(old_likelihood), file=log_file)
          log_file.flush()
        
        
        theta_alphas = copy.copy(old_theta_alphas)
        theta_betas = copy.copy(old_theta_betas)
        costs = copy.copy(old_costs)
        
        
        for i, utt in enumerate(self.config["utterances"]):
          if utt["has_theta"]:
            theta_alphas[i] = self.theta_param_prior(old_theta_alphas[i])
            theta_betas[i] = self.theta_param_prior(old_theta_betas[i])
          if utt["has_cost"] and "copy_cost" not in utt:
            costs[i] = self.cost_prior(old_costs[i])
        for i, utt in enumerate(self.config["utterances"]):
          if utt["has_cost"] and "copy_cost" in utt:
            costs[i] = costs[self.expressions2idx[utt["copy_cost"]]]
          
        rat_alpha = self.rat_alpha_prior(old_rat_alpha)
        utt_other_prob = self.utt_other_prob_prior(old_utt_other_prob)
        noise_strength = self.noise_strength_prior(old_noise_strength) 

        prior = self.compute_prior(theta_alphas, theta_betas, costs)
        new_likelihood = self.compute_likelihood(costs, rat_alpha, theta_alphas, theta_betas, utt_other_prob, noise_strength) + prior
        accept = new_likelihood > old_likelihood
        if not accept:
          bwd_prob = self.compute_trans_probs(theta_alphas, theta_betas, costs, 
                                         old_theta_alphas, old_theta_betas, old_costs)
          fwd_prob = self.compute_trans_probs(old_theta_alphas, old_theta_betas, old_costs, 
                                         theta_alphas, theta_betas, costs)                               
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
          old_rat_alpha = rat_alpha
          old_utt_other_prob = utt_other_prob
          old_noise_strength = noise_strength
        
        if it > burn_in and it % 10 == 0:
          samples.append(sample)
          if len(samples) % 1000 == 0:
            json.dump(samples, open(output_file_name, "w"))
  
        if it % 20000 == 0: 
          self.speaker_matrix_cache.clear()
          self.theta_prior_cache.clear()
  
    
      print("Accepted samples: {}".format(acceptance), file=log_file)

      json.dump(samples, open(output_file_name, "w"))
          

def main():
  parser = argparse.ArgumentParser()
  parser.add_argument("--out_dir", required=True)
  parser.add_argument("--run", required=True)
  parser.add_argument("--subject", required=False, default=None, type=int)
  
  args = parser.parse_args()
  
  out_dir = args.out_dir
  config_file_path = os.path.join(out_dir, "config.json")
  config = json.load(open(config_file_path, "r"))
  
  model = ThresholdModel(config, out_dir, args.run, subjectid=args.subject)
  model.run_mcmc()

        
if __name__ == '__main__':
  main()


