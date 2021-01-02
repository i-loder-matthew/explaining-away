setwd("~/Dropbox/Uni/RA/adaptation/explaining-away//papers/openmind//plot-sources/")

library(DescTools)
library(data.table)
library(tidyverse)
library(ggplot2)
library(grid)
library(gridExtra)
library(splines)


theme_set(theme_bw())

modals = c("bare", "might",  "could", "think",  "probably",  "looks_like", "bare_not", "other")
modals_labels = c("bare", "might",  "could", "think",  "probably",  "looks like", "bare not", "other")
modal_colors = c(
  "#E6AB02",
  "#7CB637",
  "#4C3B4D",
  "#E7298A",
  "#4381C1",
  "#08415C",
  "#FB3640",
  "#999999"
)
colscale = function(my_modals) {
  return(scale_color_manual(
    limits = modals_labels[modals_labels %in% my_modals],
    values = modal_colors[modals_labels %in% my_modals], 
    drop = T
  ))
}

colscale_fill = function(my_modals) {
  return(scale_fill_manual(
    limits = modals_labels[modals_labels %in% my_modals],
    values = modal_colors[modals_labels %in% my_modals], 
    drop = T
  ))
}



##########
# Model visualizations
##########

hdi_data.avg= read.csv(paste("../illustrations/average-speaker/hdi_samples.csv", sep=""))
hdi_data.cautious= read.csv(paste("../illustrations/cautious-speaker/hdi_samples.csv", sep=""))
hdi_data.confident= read.csv(paste("../illustrations/confident-speaker/hdi_samples.csv", sep=""))

hdi_data.avg$condition = "average speaker"
hdi_data.cautious$condition = "\"cautious\" speaker"
hdi_data.confident$condition = "\"confident\" speaker"

hdi_data.all = rbind(hdi_data.avg, hdi_data.cautious, hdi_data.confident)
hdi_data.all$condition = factor(hdi_data.all$condition, levels=c("\"cautious\" speaker", "average speaker", "\"confident\" speaker"), ordered = T)
hdi_data.all$rating_pred = hdi_data.all$rating_pred * 100
hdi_data.all$modal = factor(hdi_data.all$modal, levels = modals[modals %in% unique(hdi_data.all$modal)], labels = modals_labels[modals %in% unique(hdi_data.all$modal)], ordered=T)
viz_plot = hdi_data.all %>%  
  group_by(condition, modal, percentage_blue) %>%
  summarize(rating_pred_m = mean(rating_pred)/100)  %>%
  ggplot(aes(x=percentage_blue/100, col=modal, y=rating_pred_m, group=interaction(modal,condition), lty=modal)) +
  geom_line(size=1) + 
  geom_vline(xintercept = .6, lty=2, col="grey", size=1) +
  colscale(unique(hdi_data.all$modal)) + 
  facet_wrap(~condition) +
  theme(legend.position = "bottom", legend.box = "vertical") +
  theme(strip.text.x = element_text(size = 14), 
        legend.text=element_text(size=14), 
        legend.key.width = unit(2, "cm"),
        legend.title = element_text(size=14),
        axis.title = element_text(size=14),
        axis.text = element_text(size=12),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "transparent", color = NA),
        legend.background =  element_rect(fill = "transparent")
       ) +
  guides(col=guide_legend(title="Expression", nrow = 1, override.aes = list(size=.75, alpha = 1, fill="transparent"))) + 
  scale_linetype_manual(limits = c("bare", "might", "probably", "bare not"), values=c(1,4,5,3), name="Expression") +
ylab("expected production probability") +
  xlab("event probability")

viz_plot

ggsave(viz_plot, filename = "../plots/model-visualization-predictions.pdf", width = 30, height = 10, units = "cm")

mle_params_json = read_lines("../../../models/1_threshold_modals/visualizations/distribution-thresholds/samples.json")
mle_params = jsonlite::fromJSON(mle_params_json, flatten=TRUE)

beta_density = data.table()

beta_modals_sim = c("bare", "might", "probably", "bare_not")

for (modal in beta_modals_sim) {
  alpha_param_name = paste("alpha", modal, sep="_")
  beta_param_name = paste("beta", modal, sep="_")
  
  alpha_param = mle_params[1,alpha_param_name]
  beta_param = mle_params[1,beta_param_name]
  
  x = seq(0.001,0.999,.001)
  y = dbeta(x, alpha_param, beta_param)
  y = y / (max(y))
  
  beta_density = rbind(beta_density, data.frame(x = x, y = y, modal = gsub("_", " ", modal), condition="distributional thresholds"))

}

mle_params_json = read_lines("../../../models/1_threshold_modals/visualizations/pointwise-thresholds/samples.json")
mle_params = jsonlite::fromJSON(mle_params_json, flatten=TRUE)

for (modal in beta_modals_sim) {
  alpha_param_name = paste("alpha", modal, sep="_")
  beta_param_name = paste("beta", modal, sep="_")
  
  alpha_param = mle_params[1,alpha_param_name]
  beta_param = mle_params[1,beta_param_name]
  
  x = seq(0.001,0.999,.001)
  y = dbeta(x, alpha_param, beta_param)
  y = y / (max(y))
  y = round(y)
  
  beta_density = rbind(beta_density, data.frame(x = x, y = y, modal = gsub("_", " ", modal), condition="point estimate thresholds"))
  
}


beta_density$modal = factor(beta_density$modal, levels = modals_labels, ordered=T)
beta_density$condition = factor(beta_density$condition, levels=c("point estimate thresholds", "distributional thresholds"), ordered = T)

threshold_distrs = beta_density %>% 
  ggplot(aes(x=x, y=y, col=modal, lty=modal)) + 
  geom_line(size=1) + 
  facet_wrap(~condition) +
  xlab("threshold") +
  ylab("density") +
  colscale(unique(beta_density$modal)) +
  theme(strip.text.x = element_text(size = 14), 
        legend.text=element_text(size=14), 
        legend.title = element_text(size=16),
        axis.title = element_text(size=14),
        axis.text = element_text(size=12),
        plot.background = element_rect(fill = "transparent", color = NA),
        legend.background =  element_rect(fill = "transparent")
  ) +
  scale_linetype_manual(limits = c("bare", "might", "probably", "bare not"), values=c(1,4,5,3), name="Expression") +
    theme(legend.position = "none") 

ggsave(threshold_distrs, filename = "../plots/model-visualization-distributions.png", width = 10, height = 5.7, units = "cm")
ggsave(threshold_distrs, filename = "../plots/model-visualization-distributions.pdf", width = 30, height = 10, units = "cm")


combined_viz_plot = grid.arrange(threshold_distrs, viz_plot, heights=c(10, 12))
ggsave(combined_viz_plot, filename = "../plots/model-visualization-combined.pdf", width = 30, height = 22, units = "cm")

##########
# Speaker adaptation model results
##########

mle_params = read.csv("../../../models/2_adaptation_model/bayesian-runs/theta-cost/cautious/mle_params.csv")


beta_density = data.table()

for (modal in beta_modals) {
  if (modal == "other") {
    next
  }
  alpha_param_name = paste("alpha", modal, sep="_")
  beta_param_name = paste("beta", modal, sep="_")
  
  alpha_param = mle_params[1,alpha_param_name]
  beta_param = mle_params[1,beta_param_name]
  
  x = seq(0.001,0.999,.001)
  y = dbeta(x, alpha_param, beta_param)
  #y = y / (max(y))
  
  beta_density = rbind(beta_density, data.frame(x = x, y = y, modal = gsub("_", " ", modal), condition="cautious speaker"))
}


mle_params = read.csv("../../../models/2_adaptation_model/bayesian-runs/theta-cost/confident/mle_params.csv")



for (modal in beta_modals) {
  if (modal == "other") {
    next
  }
  alpha_param_name = paste("alpha", modal, sep="_")
  beta_param_name = paste("beta", modal, sep="_")
  
  alpha_param = mle_params[1,alpha_param_name]
  beta_param = mle_params[1,beta_param_name]
  
  x = seq(0.001,0.999,.001)
  y = dbeta(x, alpha_param, beta_param)
  #y = y / (max(y))
  
  beta_density = rbind(beta_density, data.frame(x = x, y = y, modal = gsub("_", " ", modal), condition="confident speaker"))
}

beta_density$modal = factor(beta_density$modal, levels = modals_labels, ordered=T)

mle_params = read.csv("../../../models/1_threshold_modals/runs/threshold-model-expected/mle_params.csv")

for (modal in beta_modals) {
  if (modal == "other") {
    next
  }
  alpha_param_name = paste("alpha", modal, sep="_")
  beta_param_name = paste("beta", modal, sep="_")
  
  alpha_param = mle_params[1,alpha_param_name]
  beta_param = mle_params[1,beta_param_name]
  
  x = seq(0.001,0.999,.001)
  y = dbeta(x, alpha_param, beta_param)
  #y = y / (max(y))
  
  beta_density = rbind(beta_density, data.frame(x = x, y = y, modal = gsub("_", " ", modal), condition="prior"))
}

threshold_distrs = ggplot(beta_density, aes(x=x, y=y, col=condition, lty=condition)) + 
  geom_line(size=.75) + 
  facet_wrap(~modal, ncol = 4, scales = "free_y") + 
  xlab("threshold") +
  ylab("density") +
  theme(strip.text.x = element_text(size = 14), 
        legend.text=element_text(size=14), 
        legend.title = element_text(size=16),
        axis.title = element_text(size=14),
        axis.text = element_text(size=12),
        legend.position = "bottom") +
  guides(col=guide_legend(title="Condition", nrow = 1)) +
  cond_colscale +
  scale_linetype_manual(values=c(1,1,3), breaks=c("cautious speaker", "confident speaker", "prior"), name="Condition")
  
ggsave(threshold_distrs, filename = "../plots/adaptation-posterior-thresholds.pdf", width = 30, height = 12, units = "cm")


mle_params = read.csv("../../../models/2_adaptation_model/bayesian-runs/theta-cost/cautious/mle_params.csv") 
mle_params = rbind(mle_params, read.csv("../../../models/2_adaptation_model//bayesian-runs/theta-cost/confident/mle_params.csv"))
mle_params = rbind(mle_params, read.csv("../../../models/1_threshold_modals/runs/threshold-model-expected/mle_params.csv") )

mle_params[3,"cost_might"] = 1.0
mle_params[3,"cost_probably"] = 1.0


mle_params$condition = c("cautious speaker", "confident speaker", "prior")
mle_params = mle_params %>% gather(key="Parameter", value="value", -condition)

cost_plot = mle_params %>% 
  filter(grepl("cost_", Parameter)) %>%
  mutate(Parameter = factor(gsub("cost_", "", Parameter), levels=modals, labels= modals_labels, ordered=TRUE)) %>%
  ggplot(aes(fill=condition, color=condition, y=log(value), x=Parameter)) +
    geom_bar(stat="identity", position = "dodge") +
    xlab("") + 
    ylab("log cost") +
  theme(strip.text.x = element_text(size = 14), 
        legend.text=element_text(size=12), 
        legend.title = element_text(size=14),
        axis.title = element_text(size=14),
        axis.text = element_text(size=12),
        legend.position = "bottom") +
  guides(fill=guide_legend(title="Condition", nrow = 1, override.aes = list(size=0.5)), col=guide_legend(title="Condition"), pch="none") +
  cond_colscale +
  cond_colscale_fill

ggsave(cost_plot, filename = "../plots/adaptation-posterior-costs.pdf", width = 15, height = 12, units = "cm")


hdi_data.cautious= read.csv(paste("../../../models/2_adaptation_model/bayesian-runs/theta-cost/cautious/hdi_samples.csv", sep=""))
hdi_data.confident = read.csv(paste("../../../models/2_adaptation_model/bayesian-runs/theta-cost/confident/hdi_samples.csv", sep=""))
hdi_data.prior = read.csv(paste("../../../models/1_threshold_modals/runs/threshold-model-expected//hdi_samples.csv", sep=""))
hdi_data.prior = hdi_data.prior %>% filter(cond == "might-probably") %>% filter(run < 1000)

hdi_data.cautious$condition = "cautious speaker"
hdi_data.confident$condition = "confident speaker"
hdi_data.prior$condition = "prior"
hdi_data.all = rbind(hdi_data.cautious, hdi_data.confident)
hdi_data.all$condition = factor(hdi_data.all$condition, levels=c("cautious speaker", "prior", "confident speaker"), ordered = T)
hdi_data.all$rating_pred = hdi_data.all$rating_pred * 100
hdi_data.all$modal = factor(hdi_data.all$modal, levels = modals, labels = modals_labels, ordered=T)
hdi_data.all$src = factor("model prediction", levels=c("model prediction", "experimental result"), ordered=T)
posterior_plot = hdi_data.all %>% 
  ggplot(aes(x=percentage_blue, col=modal, y=rating_pred, group=interaction(run,modal,condition), lty=src)) +
  geom_line(alpha=.01) + 
  geom_line(aes(x=percentage_blue, y=rating_pred_m, group=modal), size=1, data = hdi_data.all %>% 
              group_by(condition, modal, percentage_blue, src) %>%
              summarize(rating_pred_m = mean(rating_pred))) + 
  colscale(unique(hdi_data.all$modal)) + facet_wrap(~condition) +
  geom_vline(xintercept = 60, lty=2, col="grey", size=1) +
  theme(legend.position = "bottom", legend.box = "vertical") +
  theme(strip.text.x = element_text(size = 14), 
        legend.text=element_text(size=14), 
        legend.title = element_text(size=16),
        axis.title = element_text(size=14),
        axis.text = element_text(size=12)
  ) +
  guides(col=guide_legend(title="Expression", nrow = 1, override.aes = list(alpha = 1)), 
  lty=guide_legend(title="", nrow = 1, override.aes = list(alpha = 1, size=0.5), order = 2)) +
  ylab("predicted rating") +
  xlab("event probability") +
  geom_line(aes(x=percentage_blue, y=rating_m, group=modal), data=plot_data %>% rename(condition = pair) %>% mutate(src="experimental result")) +
  scale_linetype_manual(values=c("solid", "dashed"), labels=c("model prediction", "experimental result"), drop=F)

ggsave(posterior_plot, filename = "../plots/adaptation-posterior-predictions.png", width = 15, height = 12, units = "cm")
ggsave(posterior_plot, filename = "../plots/adaptation-posterior-predictions.pdf", width = 30, height = 12, units = "cm")



#############
# Experiment 2 
#############
d.cautious = read.csv("../../../experiments/5_adaptation_balanced/data/5_adaptation_balanced-might-trials.csv")
d.confident = read.csv("../../../experiments/5_adaptation_balanced/data/5_adaptation_balanced-probably-trials.csv")

# re-number participants in confident speaker condition
d.confident$workerid = d.confident$workerid + max(d.cautious$workerid) + 1
d.cautious$condition = "cautious speaker"
d.confident$condition = "confident speaker"

d.rep = rbind(d.cautious, d.confident)
d.rep = remove_quotes(d.rep)

d.exp_trials.cautious = read.csv("../../../experiments/5_adaptation_balanced/data/5_adaptation_balanced-might-exp_trials.csv")
d.exp_trials.confident = read.csv("../../../experiments/5_adaptation_balanced/data/5_adaptation_balanced-probably-exp_trials.csv")

d.exp_trials.confident$workerid = d.exp_trials.confident$workerid + max(d.exp_trials.cautious$workerid) + 1

exp_trials = rbind(d.exp_trials.cautious, d.exp_trials.confident)

d.rep = exclude_participants(d.rep, exp_trials)
d.rep = spread_data(d.rep)

d.rep$pair = d.rep$condition

fname = paste("../../../experiments/0_pre_test/data/0_pre_test-cond", 5 , "-trials.csv", sep="")
d.prior = read.csv(fname)
d.prior = remove_quotes(d.prior)
d.prior = spread_data(d.prior)

d.prior$pair = "Experiment 1"
d.prior = d.prior %>% mutate(condition = "prior", speaker_cond="c", catch_trial_answer_correct = -1, post_exposure = 0, catch_trial = 0)

d.rep = rbind(d.rep, d.prior)

d.rep$pair = factor(d.rep$pair, levels = c("Experiment 1", "cautious speaker", "confident speaker"), ordered = T)

plot_data = get_data_for_plotting(d.rep)
plot = plot_condition(plot_data, linetype_scale_small) + 
  geom_vline(xintercept = .60, lty=2, col="grey", size=1) +
  theme(strip.text.x = element_text(size = 14), 
        legend.text=element_text(size=14), 
        legend.title = element_text(size=16),
        axis.title = element_text(size=14),
        axis.text = element_text(size=12)) +
  colscale(unique(plot_data$modal))

ggsave(plot, filename = "../plots/exp-1-replication-ratings.pdf", width = 30, height = 12, units = "cm")

#AUCs for cuatious speaker condition
aucs.cautious = auc_for_participants(d.rep %>% filter(condition == "cautious speaker"), method=auc_method)
#AUCs for confident speaker condition
aucs.confident = auc_for_participants(d.rep %>% filter(condition == "confident speaker"), method=auc_method)

aucs.cautious$cond = "cautious speaker"
aucs.confident$cond = "confident speaker"

aucs.all = rbind(aucs.cautious, aucs.confident)
aucs.all = aucs.all %>% 
  group_by(cond) %>% 
  summarise(auc_diff_m = mean(auc_diff), 
            ci_high = ci.high(auc_diff), 
            ci_low = ci.low(auc_diff))

auc_plot.2 =  aucs.all %>%
  ggplot(aes(x=0, y=auc_diff_m, color=cond)) +
  geom_errorbar(aes(ymin=auc_diff_m-ci_low, ymax=auc_diff_m+ci_high), width=.1) +
  geom_point() +
  xlab("") +
  ylab("AUC difference (might ratings - probably ratings)") +
  theme(text = element_text(size=12),
        axis.ticks.x=element_blank(), 
        axis.text.x=element_blank(),
        panel.grid.minor=element_blank(), 
        plot.background=element_blank(),
        legend.position = "bottom") +
  guides(col=guide_legend(title="Condition")) +
  xlim(-.2, .2) +
  ylim(-8,28) + 
  scale_color_manual(
    values =c("#E6AB02", "#000000"),
    limits = c("cautious speaker", "confident speaker")
  )


g = arrangeGrob(auc_plot.1 + theme(legend.position = "none"), auc_plot.2 + theme(legend.position = "none"), ncol=2, left="AUC difference (might ratings - probably ratings)")
auc_plots = grid.arrange(g, auc_legend, heights=c(12,2))

ggsave(auc_plots, filename = "../plots/exp-1-aucs.pdf",  width=20, height=12, units = "cm")

ggsave(auc_plot.2, filename = "../plots/exp-1-auc.pdf",  width=12, height=12, units = "cm")
ggsave(auc_plot.1, filename = "../plots/exp-1-auc-orig.pdf",  width=12, height=12, units = "cm")


#c1 = compute_correlation_for_model("theta-cost-rat", d.rep, model_path_suffix = "-balanced")
c1 = compute_correlation_for_model("theta-cost", d.rep, model_path_suffix = "-balanced")
c2 = compute_correlation_for_model("cost", d.rep, model_path_suffix = "-balanced")
c3 = compute_correlation_for_model("theta", d.rep, model_path_suffix = "-balanced")
c4 = compute_correlation_for_model("prior", d.rep, model_path_suffix = "-balanced")

#c5 = compute_correlation_for_model("theta-rat", d.rep, model_path_suffix = "-balanced")
#c6 = compute_correlation_for_model("cost-rat", d.rep, model_path_suffix = "-balanced")

rbind(c1,c2,c3,c4)

hdi_data.cautious= read.csv(paste("../../../models/2_adaptation_model/bayesian-runs-balanced/theta-cost/cautious/hdi_samples.csv", sep=""))
hdi_data.confident = read.csv(paste("../../../models/2_adaptation_model/bayesian-runs-balanced/theta-cost/confident/hdi_samples.csv", sep=""))
#hdi_data.prior = read.csv(paste("../../../models/1_threshold_modals/runs/threshold-model-expected//hdi_samples.csv", sep=""))
#hdi_data.prior = hdi_data.prior %>% filter(cond == "might-probably") %>% filter(run < 1000)

hdi_data.cautious$condition = "cautious speaker"
hdi_data.confident$condition = "confident speaker"
#hdi_data.prior$condition = "prior"
hdi_data.all = rbind(hdi_data.cautious, hdi_data.confident)
hdi_data.all$condition = factor(hdi_data.all$condition, levels=c("cautious speaker", "prior", "confident speaker"), ordered = T)
hdi_data.all$rating_pred = hdi_data.all$rating_pred * 100
hdi_data.all$modal = factor(hdi_data.all$modal, levels = modals, labels = modals_labels, ordered=T)
hdi_data.all$src = factor("model prediction", levels=c("model prediction", "experimental result"), ordered=T)
posterior_plot = hdi_data.all %>% 
  ggplot(aes(x=percentage_blue, col=modal, y=rating_pred, group=interaction(run,modal,condition), lty=src)) +
  geom_line(alpha=.01) + 
  geom_line(aes(x=percentage_blue, y=rating_pred_m, group=modal), size=1, data = hdi_data.all %>% 
              group_by(condition, modal, percentage_blue, src) %>%
              summarize(rating_pred_m = mean(rating_pred))) + 
  colscale(unique(hdi_data.all$modal)) + facet_wrap(~condition) +
  geom_vline(xintercept = 60, lty=2, col="grey", size=1) +
  theme(legend.position = "bottom", legend.box = "vertical") +
  theme(strip.text.x = element_text(size = 14), 
        legend.text=element_text(size=14), 
        legend.title = element_text(size=16),
        axis.title = element_text(size=14),
        axis.text = element_text(size=12),
        plot.background = element_rect(fill = "transparent", color = NA),
        legend.background =  element_rect(fill = "transparent")
  ) +
  guides(col=guide_legend(title="Expression", nrow = 1, override.aes = list(alpha = 1)), 
         lty=guide_legend(title="", nrow = 1, override.aes = list(alpha = 1, size=0.5), order = 2)) +
  ylab("predicted rating") +
  xlab("event probability") +
  geom_line(aes(x=percentage_blue, y=rating_m, group=modal), data=plot_data %>% filter(pair != "Experiment 1") %>% rename(condition = pair) %>% mutate(src="experimental result")) +
  scale_linetype_manual(values=c("solid", "dashed"), labels=c("model prediction", "experimental result"), drop=F)

ggsave(posterior_plot, filename = "../plots/adaptation-posterior-predictions-replication.pdf", width = 30, height = 12, units = "cm")


mle_params = read.csv("../../../models/2_adaptation_model/bayesian-runs-balanced/theta-cost/cautious/mle_params.csv")

beta_density = data.table()

for (modal in beta_modals) {
  if (modal == "other") {
    next
  }
  alpha_param_name = paste("alpha", modal, sep="_")
  beta_param_name = paste("beta", modal, sep="_")
  
  alpha_param = mle_params[1,alpha_param_name]
  beta_param = mle_params[1,beta_param_name]
  
  x = seq(.001,0.999,.001)
  y = dbeta(x, alpha_param, beta_param)
  #y = y / (max(y))
  
  beta_density = rbind(beta_density, data.frame(x = x, y = y, modal = gsub("_", " ", modal), condition="cautious speaker"))
}


mle_params = read.csv("../../../models/2_adaptation_model/bayesian-runs-balanced/theta-cost/confident/mle_params.csv")


for (modal in beta_modals) {
  if (modal == "other") {
    next
  }
  alpha_param_name = paste("alpha", modal, sep="_")
  beta_param_name = paste("beta", modal, sep="_")
  
  alpha_param = mle_params[1,alpha_param_name]
  beta_param = mle_params[1,beta_param_name]
  
  x = seq(.001,0.999,.001)
  y = dbeta(x, alpha_param, beta_param)
  #y = y / (max(y))
  
  beta_density = rbind(beta_density, data.frame(x = x, y = y, modal = gsub("_", " ", modal), condition="confident speaker"))
}

beta_density$modal = factor(beta_density$modal, levels = modals_labels, ordered=T)

mle_params = read.csv("../../../models/1_threshold_modals/runs/threshold-model-expected/mle_params.csv")

for (modal in beta_modals) {
  if (modal == "other") {
    next
  }
  alpha_param_name = paste("alpha", modal, sep="_")
  beta_param_name = paste("beta", modal, sep="_")
  
  alpha_param = mle_params[1,alpha_param_name]
  beta_param = mle_params[1,beta_param_name]
  
  x = seq(.001,0.999,.001)
  y = dbeta(x, alpha_param, beta_param)
  #y = y / (max(y))
  
  beta_density = rbind(beta_density, data.frame(x = x, y = y, modal = gsub("_", " ", modal), condition="prior"))
}

threshold_distrs = ggplot(beta_density, aes(x=x, y=y, col=condition, lty=condition)) + 
  geom_line(size=.75) + 
  facet_wrap(~modal, ncol = 4, scales = "free_y") + 
  xlab("threshold") +
  ylab("density") +
  theme(strip.text.x = element_text(size = 14), 
        legend.text=element_text(size=14), 
        legend.title = element_text(size=16),
        axis.title = element_text(size=14),
        axis.text = element_text(size=12),
        legend.position = "bottom") +
  guides(col=guide_legend(title="Condition", nrow = 1)) +
  cond_colscale +
  scale_linetype_manual(values=c(1,1,3), breaks=c("cautious speaker", "confident speaker", "prior"), name="Condition")


ggsave(threshold_distrs, filename = "../plots/adaptation-posterior-thresholds-replication.pdf", width = 30, height = 12, units = "cm")



mle_params = read.csv("../../../models/2_adaptation_model/bayesian-runs-balanced/theta-cost/cautious/mle_params.csv") 
mle_params = rbind(mle_params, read.csv("../../../models/2_adaptation_model//bayesian-runs-balanced/theta-cost/confident/mle_params.csv"))
mle_params = rbind(mle_params, read.csv("../../../models/1_threshold_modals/runs/threshold-model-expected/mle_params.csv") )

mle_params[3,"cost_might"] = 1.0
mle_params[3,"cost_probably"] = 1.0


mle_params$condition = c("cautious speaker", "confident speaker", "prior")
mle_params = mle_params %>% gather(key="Parameter", value="value", -condition)

cost_plot = mle_params %>% 
  filter(grepl("cost_", Parameter)) %>%
  mutate(Parameter = factor(gsub("cost_", "", Parameter), levels=modals, labels= modals_labels, ordered=TRUE)) %>%
  ggplot(aes(fill=condition, color=condition, y=log(value), x=Parameter)) +
  geom_bar(stat="identity", position = "dodge") +
  xlab("") + 
  ylab("log cost") +
  theme(strip.text.x = element_text(size = 14), 
        legend.text=element_text(size=12), 
        legend.title = element_text(size=14),
        axis.title = element_text(size=14),
        axis.text = element_text(size=12),
        legend.position = "bottom") +
  guides(fill=guide_legend(title="Condition", nrow = 1, override.aes = list(size=0.5)), col=guide_legend(title="Condition"), pch="none") +
  cond_colscale +
  cond_colscale_fill

ggsave(cost_plot, filename = "../plots/adaptation-posterior-costs-replication.pdf", width = 15, height = 12, units = "cm")



#### 
# Experiment 3
####

d.cautious = read.csv("../../../experiments/12_comprehension_coins_balanced/data/12_comprehension_coins_balanced-might-trials.csv")
d.confident = read.csv("../../../experiments/12_comprehension_coins_balanced/data/12_comprehension_coins_balanced-probably-trials.csv")
# re-number participants in confident speaker condition
d.confident$workerid = d.confident$workerid + max(d.cautious$workerid) + 1
d.cautious$condition = "cautious speaker"
d.confident$condition = "confident speaker"

d.comp = rbind(d.cautious, d.confident)
d.comp = remove_quotes(d.comp)
d.comp$catch_trial_answer_correct = -1

d.exp_trials.cautious = read.csv("../../../experiments/12_comprehension_coins_balanced/data/12_comprehension_coins_balanced-might-exp_trials.csv")
d.exp_trials.confident = read.csv("../../../experiments/12_comprehension_coins_balanced/data/12_comprehension_coins_balanced-probably-exp_trials.csv")

d.exp_trials.confident$workerid = d.exp_trials.confident$workerid + max(d.exp_trials.cautious$workerid) + 1

exp_trials = rbind(d.exp_trials.cautious, d.exp_trials.confident)

d.comp = exclude_participants(trials = (d.comp %>% mutate(catch_trial = 0)), exp_trials = exp_trials, cutoff = 4)
d.comp[d.comp$color=="orange", ]$percentage_blue = 100 - d.comp[d.comp$color=="orange", ]$percentage_blue

d.comp = d.comp %>% group_by(workerid, modal, color) %>% mutate(rating_norm = rating / sum(rating)) %>% ungroup()

comp.plot_data = d.comp %>% group_by(percentage_blue, modal, condition) %>% 
  summarize(rating_norm_mu = mean(rating_norm), 
            rating_norm_ci_low=ci.low(rating_norm), 
            rating_norm_ci_high=ci.high(rating_norm)) 

comp.plot = comp.plot_data %>% 
  ggplot(aes(x=percentage_blue, y=rating_norm_mu, col=condition)) + 
  geom_line(size=1) + 
  facet_wrap(~modal) +
  xlab("event probabilty") +
  ylab("mean normalized rating") +
  guides(col=guide_legend(title="", nrow = 1)) + 
  theme(legend.position="bottom", 
        strip.text.x = element_text(size = 14), 
        legend.text=element_text(size=14), 
        legend.title = element_text(size=16),
        axis.title = element_text(size=14),
        axis.text = element_text(size=12)) + 
  geom_errorbar(aes(ymin=rating_norm_mu - rating_norm_ci_low, ymax=rating_norm_mu + rating_norm_ci_high), width=5, size=1)+
  scale_color_manual(
    values =c("#E6AB02", "#000000"),
    limits = c("cautious speaker", "confident speaker")
  )
ggsave(comp.plot, file="../plots/exp-2-ratings.pdf", width = 30, height = 12, units = "cm")

linetype_scale_comp = scale_linetype_manual(limits = c("bare", "might", "probably"), values=c(1,4,5))

comp.plot_condition = comp.plot_data %>% 
  ggplot(aes(x=percentage_blue, y=rating_norm_mu, col=modal, lty=modal)) + 
  facet_wrap(~condition) +
  xlab("event probabilty") +
  ylab("mean normalized rating") +
  geom_vline(xintercept = 60, lty=2, col="grey", size=1) +
  theme(legend.position="bottom", 
        legend.box = "vertical",
        strip.text.x = element_text(size = 14), 
        legend.text=element_text(size=14), 
        legend.title = element_text(size=16),
        axis.title = element_text(size=14),
        axis.text = element_text(size=12),
        legend.key.width = unit(2, "cm")) + 
  linetype_scale_comp +
  geom_line(size=1) + 
  colscale(unique(comp.plot_data$modal)) +
  guides(lty=guide_legend(title="Expression", override.aes = list(lty=c(1,4,5))), col=guide_legend(title="Expression", nrow = 1)) +
  geom_errorbar(aes(ymin=rating_norm_mu - rating_norm_ci_low, ymax=rating_norm_mu + rating_norm_ci_high), width=5, size=1, lty=1)

ggsave(comp.plot_condition, file="../plots/exp-2-condition-ratings.png", width = 15, height = 12, units = "cm")

#####
# comprehension model
#####

compute_correlation_for_comp_model = function(model_type, exp_data, model_path_suffix="") {
  
  exp_data = exp_data %>% mutate(rating = rating_norm)
  
  hdi_data.cautious = read.csv(paste("../../../models/3_comprehension_model/bayesian-runs", model_path_suffix, "/", model_type, "/cautious/hdi_samples.csv", sep="")) %>% mutate(condition = "cautious speaker")
  hdi_data.confident = read.csv(paste("../../../models/3_comprehension_model/bayesian-runs", model_path_suffix, "/", model_type, "/confident/hdi_samples.csv", sep=""))  %>% mutate(condition = "confident speaker")
  
  r2_cautious = post_adaptation_correlation(hdi_data.cautious, exp_data %>% filter(condition =="cautious speaker"))
  r2_confident = post_adaptation_correlation(hdi_data.confident, exp_data %>% filter(condition =="confident speaker"))
  
  r2_all = post_adaptation_correlation(rbind(hdi_data.cautious, hdi_data.confident), exp_data)
  cor_row = data.frame(model=model_type, r2_cautious = r2_cautious, r2_confident=r2_confident, r2_all=r2_all)
  return(cor_row)
}

c1 = compute_correlation_for_comp_model("theta-cost", d.comp, model_path_suffix = "-balanced")
c2 = compute_correlation_for_comp_model("cost", d.comp, model_path_suffix = "-balanced")
c3 = compute_correlation_for_comp_model("theta", d.comp, model_path_suffix = "-balanced")
c4 = compute_correlation_for_comp_model("prior", d.comp, model_path_suffix = "-balanced")

rbind(c1,c2,c3, c4)

hdi_data.cautious= read.csv(paste("../../../models/3_comprehension_model/bayesian-runs-balanced/theta-cost/cautious/hdi_samples.csv", sep=""))
hdi_data.confident = read.csv(paste("../../../models/3_comprehension_model/bayesian-runs-balanced/theta-cost/confident/hdi_samples.csv", sep=""))

hdi_data.cautious$condition = "cautious speaker"
hdi_data.confident$condition = "confident speaker"
hdi_data.all = rbind(hdi_data.cautious, hdi_data.confident)
hdi_data.all$condition = factor(hdi_data.all$condition, levels=c("cautious speaker", "prior", "confident speaker"), ordered = T)
hdi_data.all$modal = factor(hdi_data.all$modal, levels = modals, labels = modals_labels, ordered=T)
hdi_data.all$src = factor("model prediction", levels=c("model prediction", "experimental result"), ordered=T)
posterior_plot = hdi_data.all %>% 
    ggplot(aes(x=percentage_blue, col=condition, y=rating_pred, group=interaction(src,run,modal,condition))) +
    geom_line(aes(x=percentage_blue, y=rating_pred_m, group=condition), size=1, data = hdi_data.all %>% 
                               group_by(condition, modal, percentage_blue, src) %>%
                               summarize(rating_pred_m = mean(rating_pred))) + 
    facet_wrap(~modal) +
    theme(legend.position = "bottom", legend.box = "vertical") +
    theme(strip.text.x = element_text(size = 14), 
        legend.text=element_text(size=14), 
        legend.title = element_text(size=16),
        axis.title = element_text(size=14),
        axis.text = element_text(size=12)) + 
    guides(col=guide_legend(title="", nrow = 1, override.aes = list(alpha = 1))
                     ) +
    ylab("predicted rating") +
    xlab("event probability") +
  scale_color_manual(
    values =c("#E6AB02", "#000000"),
    limits = c("cautious speaker", "confident speaker")
  )


posterior_plot_combined = hdi_data.all %>% 
  ggplot(aes(x=percentage_blue, col=modal, y=rating_pred, lty=src, group=interaction(src,run,modal,condition))) +
  geom_line(alpha=.01) + 
  geom_line(aes(x=percentage_blue, y=rating_pred_m, group=modal), size=1, data = hdi_data.all %>% 
              group_by(condition, modal, percentage_blue, src) %>%
              summarize(rating_pred_m = mean(rating_pred))) + 
  facet_wrap(~condition) +
  theme(legend.position = "bottom", legend.box = "vertical") +
  theme(strip.text.x = element_text(size = 14), 
        legend.text=element_text(size=14), 
        legend.title = element_text(size=14),
        axis.title = element_text(size=14),
        axis.text = element_text(size=12)) + 
  colscale(unique(hdi_data.all$modal)) + 
  guides(col=guide_legend(title="Expression", nrow = 1, override.aes = list(alpha = 1)),
         lty=guide_legend(title="", nrow = 1, override.aes = list(size = 0.5))) +
  ylab("predicted rating") +
  xlab("event probability") + 
  geom_line(aes(x=percentage_blue, y=rating_norm_mu, group=interaction(src,modal,condition)), data= comp.plot_data %>% mutate(src="experimental result")) +
  scale_linetype_manual(values=c("solid", "dashed"), labels=c("model prediction", "experimental result"), drop=F)


ggsave(posterior_plot, file="../plots/adaptation-posterior-comp.pdf", width = 30, height = 12, units = "cm")
ggsave(posterior_plot_combined, file="../plots/adaptation-posterior-comp-data.png", width = 15, height = 12, units = "cm")
ggsave(posterior_plot_combined, file="../plots/adaptation-posterior-comp-data.pdf", width = 30, height = 12, units = "cm")


####
# Original comprehension experiment
####

d.cautious = read.csv("../../../experiments/2_comprehension/data/2_comprehension-might-trials.csv")
d.confident = read.csv("../../../experiments/2_comprehension/data/2_comprehension-probably-trials.csv")
# re-number participants in confident speaker condition
d.confident$workerid = d.confident$workerid + max(d.cautious$workerid) + 1
d.cautious$condition = "cautious speaker"
d.confident$condition = "confident speaker"

d.comp = rbind(d.cautious, d.confident)
d.comp = remove_quotes(d.comp)
d.comp$catch_trial_answer_correct = -1

d.exp_trials.cautious = read.csv("../../../experiments/2_comprehension/data/2_comprehension-might-exp_trials.csv")
d.exp_trials.confident = read.csv("../../../experiments/2_comprehension/data/2_comprehension-probably-exp_trials.csv")

d.exp_trials.confident$workerid = d.exp_trials.confident$workerid + max(d.exp_trials.cautious$workerid) + 1

exp_trials = rbind(d.exp_trials.cautious, d.exp_trials.confident)

d.comp = exclude_participants(trials = (d.comp %>% mutate(catch_trial = 0)), exp_trials = exp_trials, cutoff = 3)
d.comp[d.comp$color=="orange", ]$percentage_blue = 100 - d.comp[d.comp$color=="orange", ]$percentage_blue

d.comp = d.comp %>% group_by(workerid, modal, color) %>% mutate(rating_norm = rating / sum(rating)) %>% ungroup()

comp.plot_data = d.comp %>% group_by(percentage_blue, modal, condition) %>% 
  summarize(rating_norm_mu = mean(rating_norm), 
            rating_norm_ci_low=ci.low(rating_norm), 
            rating_norm_ci_high=ci.high(rating_norm)) 

comp.plot = comp.plot_data %>% 
  ggplot(aes(x=percentage_blue, y=rating_norm_mu, col=condition)) + 
  geom_line(size=1) + 
  facet_wrap(~modal) +
  xlab("event probabilty") +
  ylab("mean normalized rating") +
  guides(col=guide_legend(title="", nrow = 1)) + 
  theme(legend.position="bottom", 
        strip.text.x = element_text(size = 14), 
        legend.text=element_text(size=14), 
        legend.title = element_text(size=16),
        axis.title = element_text(size=14),
        axis.text = element_text(size=12)) + 
  geom_errorbar(aes(ymin=rating_norm_mu - rating_norm_ci_low, ymax=rating_norm_mu + rating_norm_ci_high), width=5, size=1) +
  scale_color_manual(
    values =c("#E6AB02", "#000000"),
    limits = c("cautious speaker", "confident speaker")
  )

ggsave(comp.plot, file="../plots/exp-2-ratings-orig.pdf", width = 30, height = 12, units = "cm")


# distrubutions over parameterizations

x = c("A", "B", "C")
y = c(0.15, 0.6, 0.15)
d = data.frame(x=x, y=y)

d %>% ggplot(aes(x=x, y=y)) + geom_bar(stat="identity") + xlab("") + ylab("") + theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + facet_wrap(~"XYZ") + ylim(0,.9)

x = c("A", "B", "C")
y = c(0.05, 0.9, 0.05)
d = data.frame(x=x, y=y)

d %>% ggplot(aes(x=x, y=y)) + geom_bar(stat="identity") + xlab("") + ylab("") + theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + facet_wrap(~"XYZ") + ylim(0,.9)


x = c("A", "B", "C")
y = c(0.8, 0.15, 0.05)
d = data.frame(x=x, y=y)

d %>% ggplot(aes(x=x, y=y)) + geom_bar(stat="identity") + xlab("") + ylab("") + theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + facet_wrap(~"XYZ") + ylim(0,.9)

x = c("A", "B", "C")
y = c(0.83, 0.15, 0.02)
d = data.frame(x=x, y=y)

d %>% ggplot(aes(x=x, y=y)) + geom_bar(stat="identity") + xlab("") + ylab("") + theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + facet_wrap(~"XYZ") + ylim(0,.9)

x = c("A", "B", "C")
y = c(0.05, 0.15, 0.8)
d = data.frame(x=x, y=y)

d %>% ggplot(aes(x=x, y=y)) + geom_bar(stat="identity") + xlab("") + ylab("") + theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + facet_wrap(~"XYZ") + ylim(0,.9)

x = c("A", "B", "C")
y = c(0.02, 0.15, 0.83)
d = data.frame(x=x, y=y)

d %>% ggplot(aes(x=x, y=y)) + geom_bar(stat="identity") + xlab("") + ylab("") + theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + facet_wrap(~"XYZ") + ylim(0,.9)


