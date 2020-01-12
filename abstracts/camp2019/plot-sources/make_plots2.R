setwd("~/Documents/research/explaining-away/experiments/")

library(ggplot2)
library(dplyr)
library(tidyr)
library(data.table)
library(gridExtra)
library(DescTools)
library(splines)
source("06_exp_away/analysis/helpers.R")
theme_set(theme_bw())

colscale = scale_color_manual(values=c("#7CB637", "#666666", "#4381C1")) 
colscale_fill = scale_fill_manual(values=c("#7CB637", "#666666", "#4381C1")) 

## Prepare data functions

format_data = function(d) {
  drops <- c("modal1","rating1")
  d2 = d[ , !(names(d) %in% drops)]
  setnames(d2, old=c("rating2","modal2"), new=c("rating", "modal"))
  
  drops <- c("modal2","rating2")
  d3 = d[ , !(names(d) %in% drops)]
  setnames(d3, old=c("rating1","modal1"), new=c("rating", "modal"))
  
  drops <- c("modal2", "rating2", "modal1", "rating1")
  d4 = d[ , !(names(d) %in% drops)]
  d4$rating = d4$rating_other
  d4$modal = "other"
  
  d = rbind(d2, d3, d4)
  
  d$modal = gsub('"', '', d$modal)
  d$modal = factor(d$modal, levels = c("might", "probably", "other"), ordered = T)
  
  d$percent_window_f = factor(d$percent_window)
  
  d_aisle = d %>% filter(.,grepl("aisle", type))
  d_window = d %>% filter(.,grepl("window", type))
  
  d_aisle_reverse = d_aisle
  d_aisle_reverse$percent_window = 100-d_aisle$percent_window
  
  d_comparison = rbind(d_window, d_aisle_reverse)
  d_comparison$percent_window_f = factor(d_comparison$percent_window)
  
  return(d_comparison)
}

format_exp_trials = function(d) {
  
  if (d$condtion == '1' || d$condtion == '2') {
    d_window_60 = d %>% filter(.,grepl("60", image))
    d_window_25 = d %>% filter(.,grepl("25", image))
    d_window_100 = d %>% filter(.,grepl("100", image))
    d_aisle_25 = d %>% filter(.,grepl("75", image))
    d_aisle_60 = d %>% filter(.,grepl("40", image))
    
    d_window_60$prob = 60
    d_aisle_60$prob = 60
    d_window_100$prob = 100
    d_window_25$prob = 25
    d_aisle_25$prob = 25
    
    d_output = rbind(d_window_60, d_window_25, d_window_100, d_aisle_25, d_aisle_60)
  } else if (d$condtion == '3' || d$condtion == '4') {
    d_window_60 = d %>% filter(.,grepl("60", image))
    d_window_90 = d %>% filter(.,grepl("90", image))
    d_window_100 = d %>% filter(.,grepl("100", image))
    d_aisle_90 = d %>% filter(.,grepl("10", image))
    d_aisle_60 = d %>% filter(.,grepl("40", image))
    
    d_window_60$prob = 60
    d_window_90$prob = 90
    d_window_100$prob = 100
    d_aisle_60$prob = 60
    d_aisle_90$prob = 90
    
    d_output = rbind(d_window_60, d_window_90, d_window_100, d_aisle_90, d_aisle_60)
  } 
  
  return(d_output)
}



## Import norming study data:

d1 = format_data(read.csv("02_norming/data/02_norming_cond1-trials.csv"))
d2 = format_data(read.csv("02_norming/data/02_norming_cond2-trials.csv"))
d3 = format_data(read.csv("05_norming/data/05_norming_cond3-trials.csv"))


# combine data: 
d1$Answer.condition = "optimist"
d2$Answer.condition = "pessimist"
d3$Answer.condition = "neutral"
d3$condition = 3

## Exclude Random Responses

exclude_random = function(d) {
  d_overall_means = d %>%
    group_by(modal, workerid) %>% 
    summarise(rating_m_overall = mean(rating))
  
  d_indiv_means =  d %>%
    group_by(modal,percent_window, workerid) %>% 
    summarise(rating_m = mean(rating))
  
  d_indiv_merged = merge(d_indiv_means, d_overall_means, by=c("workerid", "modal"))
  
  cors = d_indiv_merged %>%
    group_by(workerid) %>%
    summarise(corr = cor(rating_m, rating_m_overall))
  
  exclude = cors %>%
    filter(corr > 0.75) %>%
    .$workerid
  
  print(paste("Excluded", length(exclude), "participants based on random responses."))
  
  d = d %>% filter(!(workerid %in% exclude))
}

d1 = exclude_random(d1)
d2 = exclude_random(d2)
d3 = exclude_random(d3)

## Combine norming data:

d2$workerid = d2$workerid + max(d1$workerid) + 1
d3$workerid = d3$workerid + max(d2$workerid) + 1

d_norm = rbind(d1, d2, d3)

plot_conditions = function(d) {
  d_means = d %>% 
    group_by(workerid, percent_window, modal, Answer.condition) %>% 
    summarise(participant_mean = mean(rating)) %>%
    group_by(percent_window, modal, Answer.condition) %>%
    summarise(mu = mean(participant_mean),
              ci_high = ci.high(participant_mean), 
              ci_low = ci.low(participant_mean))
  
  return(d_means)
}

d_means.norming = plot_conditions(d_norm)
d_means.norming$experiment = "Exp 1: Norming"


## Import Explaining Away Data

d1_exp = format_data(read.csv("06_exp_away/data/06_exp_away_cond1-trials.csv"))
d2_exp = format_data(read.csv("04_exp_away/data/04_exp_away_cond2-trials.csv"))
d3_exp = format_data(read.csv("04_exp_away/data/04_exp_away_cond3-trials.csv"))
d4_exp = format_data(read.csv("04_exp_away/data/04_exp_away_cond4-trials.csv"))

exp_trials1 = format_exp_trials(read.csv("06_exp_away/data/06_exp_away_cond1-exp_trials.csv"))
exp_trials2 = format_exp_trials(read.csv("04_exp_away/data/04_exp_away_cond2-exp_trials.csv"))
exp_trials3 = format_exp_trials(read.csv("04_exp_away/data/04_exp_away_cond3-exp_trials.csv"))
exp_trials4 = format_exp_trials(read.csv("04_exp_away/data/04_exp_away_cond4-exp_trials.csv"))

d1_exp$Answer.condition = "optimist"
d2_exp$Answer.condition = "confident"
d3_exp$Answer.condition = "pessimist"
d4_exp$Answer.condition = "cautious"

## Combine data and exclude random responses

d2_exp$workerid = d2_exp$workerid + max(d1_exp$workerid) + 1
d3_exp$workerid = d3_exp$workerid + max(d2_exp$workerid) + 1
d4_exp$workerid = d4_exp$workerid + max(d3_exp$workerid) + 1

d_exp = rbind(d1_exp, d2_exp, d3_exp, d4_exp)
d_exp = exclude_random(d_exp)

d_means.exp = plot_conditions(d_exp)
d_means.exp$experiment = "Exp 2: Explaining Away"

## Combine all data into a single frame:

d_means = rbind(d_means.norming, d_means.exp)

d_means$experiment = factor(d_means$experiment, levels=c("Exp 1: Norming", "Exp 2: Explaining Away"), labels=c("Exp 1: Norming", "Exp 2: Explaining Away"),
                            ordered = TRUE)

## Plot data:

plot_2conditions = function(d, condition1, condition2, plot_title) {
  d$experiment = plot_title
  
  d = d %>%
    filter(Answer.condition == condition1 | Answer.condition == condition2)
  p1 <- ggplot(d, aes(x=percent_window, y=mu, col=modal, linetype=Answer.condition, pch=modal)) + 
    xlab("% window seat") +
    ylab("mean ratings") +
    geom_errorbar(aes(ymin=mu-ci_low, ymax=mu+ci_high), width=.1) +
    geom_line() +
    geom_point(size=3) +
    guides(linetype=guide_legend(title="Condition"),
           pch=guide_legend(title="Expr."),
           col=guide_legend(title="Expr.")) +
    facet_wrap(~experiment, scales = "free") +
    theme(legend.position="none")
  
  return(p1)

}

# Norming Optimist & Pessimist
plot12.norming = plot_2conditions(d_means.norming, "optimist", "pessimist", "Exp 1: Optimist-Pessimist")

ggsave("../abstracts/camp2019/plots/norming1.pdf", plot=plot12.norming, width=7, height=5, units="cm", scale = 1.75)

# Norming Optimist & Neutral
plot13.norming = plot_2conditions(d_means.norming, "optimist", "neutral", "Exp 1: Optimist-Neutral")

ggsave("../abstracts/camp2019/plots/norming2.pdf", plot=plot13.norming, width=7, height=5, units="cm", scale = 1.75)

# Norming Pessimist & Neutral
plot23.norming = plot_2conditions(d_means.norming, "pessimist", "neutral", "Exp 1: Pessimist-Neutral")

ggsave("../abstracts/camp2019/plots/norming3.pdf", plot=plot12.norming, width=7, height=5, units="cm", scale = 1.75)

# Explaining Away Cautious and Confident
plot24.exp = plot_2conditions(d_means.exp, "confident", "cautious", "Exp 2: Confident-Cautious")

ggsave("../abstracts/camp2019/plots/exp1.pdf", plot=plot12.norming, width=7, height=5, units="cm", scale = 1.75)

# Explaining Away Pessimist and Cautious
plot34.exp = plot_2conditions(d_means.exp, "pessimist", "cautious", "Exp 2: Pessimist-Cautious")

ggsave("../abstracts/camp2019/plots/exp2.pdf", plot=plot12.norming, width=7, height=5, units="cm", scale = 1.75)

# Explaining Away Optimist and Confident
plot24.exp = plot_2conditions(d_means.exp, "confident", "optimist", "Exp 2: Confident-Optimist")

ggsave("../abstracts/camp2019/plots/exp3.pdf", plot=plot12.norming, width=7, height=5, units="cm", scale = 1.75)
