library(tidyverse)
library(ggplot2)


#### Helpers


myCenter <- function(x) {
  if (is.numeric(x)) { return(x - mean(x)) }
  if (is.factor(x)) {
    x <- as.numeric(x)
    return(x - mean(x))
  }
  if (is.data.frame(x) || is.matrix(x)) {
    m <- matrix(nrow=nrow(x), ncol=ncol(x))
    colnames(m) <- paste("c", colnames(x), sep="")
    for (i in 1:ncol(x)) {
      if (is.factor(x[,i])) {
        y <- as.numeric(x[,i])
        m[,i] <- y - mean(y, na.rm=T)
      }
      if (is.numeric(x[,i])) {
        m[,i] <- x[,i] - mean(x[,i], na.rm=T)
      }
    }
    return(as.data.frame(m))
  }
}

se <- function(x)
{
  y <- x[!is.na(x)] # remove the missing values, if any
  sqrt(var(as.vector(y))/length(y))
}

zscore <- function(x){
  ## Returns z-scored values
  x.mean <- mean(x)
  x.sd <- sd(x)
  
  x.z <- (x-x.mean)/x.sd
  
  return(x.z)
}

## for bootstrapping 95% confidence intervals
library(bootstrap)
theta <- function(x,xdata,na.rm=T) {mean(xdata[x],na.rm=na.rm)}
ci.low <- function(x,na.rm=T) {
  mean(x,na.rm=na.rm) - quantile(bootstrap(1:length(x),1000,theta,x,na.rm=na.rm)$thetastar,.025,na.rm=na.rm)}
ci.high <- function(x,na.rm=T) {
  quantile(bootstrap(1:length(x),1000,theta,x,na.rm=na.rm)$thetastar,.975,na.rm=na.rm) - mean(x,na.rm=na.rm)}

####

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
colscale2 = scale_colour_brewer(limits=modals_labels, drop=T, type="qual", palette="Dark2")

cond_colscale = scale_color_manual(
  values =c("#F8766D", "#00BFC4", "#999999"),
  limits = c("cautious speaker", "confident speaker", "prior")
  )

cond_colscale_fill = scale_fill_manual(
  values =c("#F8766D", "#00BFC4", "#999999"),
  limits = c("cautious speaker", "confident speaker", "prior")
)

# computes the fraction of correct catch trials for each
# participant
get_correct_catch_trial_counts = function (data) {
  ret = data %>% 
    filter(., catch_trial == 1) %>%
    group_by(workerid) %>%
    summarise(catch_perf = sum(catch_trial_answer_correct))
  return(ret)
}

# removes quotes from text values
remove_quotes = function(d) {
  d = d %>% mutate_if(is.factor, ~gsub('"', '', .))
  return(d)
}

exclude_participants = function(trials, exp_trials, cutoff = 12) {
  

  
  catch_trial_perf.trials = get_correct_catch_trial_counts(trials)
  catch_trial_perf.exp_trials = get_correct_catch_trial_counts(exp_trials)
  catch_trial_perf.all = rbind(catch_trial_perf.trials, catch_trial_perf.exp_trials) %>%
    group_by(workerid) %>%
    summarise(catch_perf = sum(catch_perf))

  print(catch_trial_perf.all)
  
  exclude = catch_trial_perf.all %>%
    filter(catch_perf < cutoff) %>%
    .$workerid
  
  print(paste("Excluded", length(exclude), "participants."))
  print(exclude)
  
  #final data
  d = trials %>% filter(., !(workerid %in% exclude))
  return(d)
}


spread_data = function(d) {

  modal1 = d$modal1[1]
  modal2 = d$modal2[1]

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
  colnames(d)[colnames(d)=="percent_window"] <- "percentage_blue"
  
  d$modal = factor(d$modal)
  d$percentage_blue_f = factor(d$percentage_blue)
  d_window = d %>% filter(., grepl("window", type))
  d_aisle = d %>% filter(., grepl("aisle", type))
  
  d_aisle_reverse = d_aisle
  d_aisle_reverse$percentage_blue = 100-d_aisle$percentage_blue
  
  d_comparison = rbind(d_window, d_aisle_reverse)
  d_comparison$window= grepl("window", d_comparison$type)
  d_comparison$percentage_blue_f = factor(d_comparison$percentage_blue)
  
  #d_comparison$modal = factor(d_comparison$modal, levels = c(modal1, modal2, "other"), ordered = TRUE)
  
  return(d_comparison)
}


get_data_for_plotting = function(d) {
  d_by_modal_col = d %>% 
    group_by(modal,percentage_blue, pair) %>% 
    summarise(rating_m = mean(rating * 100), 
              ci_low=ci.low(rating * 100), 
              ci_high=ci.high(rating * 100))
  
  d_by_modal_col$modal = factor(d_by_modal_col$modal, levels=modals, labels = modals_labels, ordered = T)
  return(d_by_modal_col)
}

get_data_for_indiv_plotting = function(d) {
  d_by_modal_col = d %>% 
    group_by(modal,percentage_blue, pair, workerid) %>% 
    summarise(rating_m = mean(rating * 100), 
              ci_low=ci.low(rating * 100), 
              ci_high=ci.high(rating * 100))
  
  d_by_modal_col$modal = factor(d_by_modal_col$modal, levels=modals, labels = modals_labels, ordered = T)
  return(d_by_modal_col)
}


plot_condition = function(d) {
  p = d %>% 
    plot_condition_no_errorbar() +
    geom_errorbar(aes(ymin=rating_m-ci_low, ymax=rating_m+ci_high), width=.05, size=1)
  return(p)
}

plot_condition_no_errorbar = function(d) {
  p = d %>% 
    ggplot(aes(x=percentage_blue/100, y=rating_m, group=modal, col=modal)) + 
    geom_point(aes(col=modal), size=1) + 
    geom_line(size=1) + 
    xlab("event probability") +   
    ylab("mean rating") + 
    facet_wrap(~pair) + 
    colscale(modals_labels) + 
    guides(col=guide_legend(title="Expression", nrow = 1)) + 
    theme(legend.position="bottom", 
          legend.text=element_text(size=14), 
          strip.text.x = element_text(size = 14),
          axis.title = element_text(size=14),
          axis.text = element_text(size=12))
  return(p)
}

extract_legend = function (a.gplot) {
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}

plot_posterior = function(exp_data, hdi_data) {
  
  cond_name = exp_data$pair[1]
  pred_data = hdi_data %>% 
    filter(cond == cond_name) %>%
    group_by(percentage_blue, modal) %>%
    summarise(rating_pred_m = mean(rating_pred*100), 
              ci_low_pred = quantile(rating_pred*100, 0.025), 
              ci_high_pred = quantile(rating_pred*100, 0.975)) %>%
    mutate(pair = cond_name)
  
  pred_data$modal = factor(pred_data$modal, 
                           levels = modals, 
                           labels = modals_labels, 
                           ordered = TRUE)
  
  exp_data = exp_data %>% 
    group_by(percentage_blue, modal, pair) %>%
    summarise(rating_m = mean(rating*100), 
              ci_low = ci.low(rating*100), 
              ci_high = ci.high(rating*100)) %>%
    mutate(type ="exp")
  exp_data$modal = factor(exp_data$modal, 
                          levels = modals, 
                          labels = modals_labels, 
                          ordered = TRUE)
  
  merged_data = merge(pred_data, exp_data, by=c("percentage_blue", "modal"))
  model = lm(rating_pred_m ~ rating_m, data=merged_data)
  
  r2 = round(summary(model)$r.squared, 3)
  r2e = geom_text(x=35, 
                  y=95, 
                  hjust=0, 
                  label=paste('R^2~"(27) = ', r2,'"',sep=""), 
                  color="black", 
                  parse=TRUE, 
                  size=4)
  
  pred_data2 = pred_data %>%
    rename(rating_m = rating_pred_m, ci_high = ci_high_pred, ci_low = ci_low_pred) %>%
    mutate(ci_low = rating_m - ci_low, ci_high = ci_high - rating_m, type="a_model")
  
  p_combined = rbind(exp_data, pred_data2) %>%
    ggplot(aes(x=percentage_blue/100, y=rating_m, col=modal, linetype=type)) + 
    geom_line(size=.5) + 
    xlab("event probability") +   
    ylab("mean rating") + 
    facet_wrap(~pair) +
    geom_errorbar(aes(ymin=rating_m - ci_low, 
                      ymax= rating_m+ci_high, lty="a_model"), width=.05, size=.5) +
    theme(legend.position="bottom", 
          legend.box = "vertical",
          legend.text=element_text(size=14), 
          strip.text.x = element_text(size = 14),
          axis.title = element_text(size=14),
          axis.text = element_text(size=12)) +
    guides(col=guide_legend(title="Expression", nrow = 1),
           lty=guide_legend(title="", nrow=1)) + 
    scale_linetype_manual(values=c("solid","dashed"), labels=c("model prediction", "observed result")) +
    colscale(unique(exp_data$modal)) +
    r2e +
    ylim(0,100)
  
  return(p_combined)
}

pretest_loo_correlation_for_condition = function(condition, hdi_data_all, experiment_data_path, hdi_data_path) {
  

  exp_data_cond = read.csv(paste(experiment_data_path, "/0_pre_test-cond", condition, "-trials.csv", sep = ""))
  exp_data_cond = remove_quotes(exp_data_cond)
  exp_data_cond = spread_data(exp_data_cond)
  
  cond_name = exp_data_cond$pair[1]
  
  
  exp_data_cond = get_data_for_plotting(exp_data_cond)
  
  hdi_data_cond = read.csv(paste(hdi_data_path, "/threshold-model-expected-no-cond-", condition, "/hdi_samples.csv", sep = ""))
  hdi_data_cond = hdi_data_cond %>% 
    filter(cond == cond_name) %>%
    group_by(percentage_blue, modal) %>%
    summarise(rating_pred_m = mean(rating_pred*100), 
              ci_low_pred = quantile(rating_pred*100, 0.025), 
              ci_high_pred = quantile(rating_pred*100, 0.975)) %>%
    mutate(pair = cond_name)
  hdi_data_cond$modal = factor(hdi_data_cond$modal, 
                           levels = modals, 
                           labels = modals_labels, 
                           ordered = TRUE)
  
  hdi_data_all = hdi_data_all %>% 
    filter(cond == cond_name) %>%
    group_by(percentage_blue, modal) %>%
    summarise(rating_pred_m = mean(rating_pred*100), 
              ci_low_pred = quantile(rating_pred*100, 0.025), 
              ci_high_pred = quantile(rating_pred*100, 0.975)) %>%
    mutate(pair = cond_name)
  hdi_data_all$modal = factor(hdi_data_all$modal, 
                               levels = modals, 
                               labels = modals_labels, 
                               ordered = TRUE)
  
  merged_data_cond = merge(hdi_data_cond, exp_data_cond, by=c("percentage_blue", "modal"))
  model_cond = lm(rating_pred_m ~ rating_m, data=merged_data_cond)
  
  
  
  r2_cond = round(summary(model_cond)$r.squared, 3)
  
  merged_data_all = merge(hdi_data_all, exp_data_cond, by=c("percentage_blue", "modal"))
  model_all = lm(rating_pred_m ~ rating_m, data=merged_data_all)
  
  r2_all = round(summary(model_all)$r.squared, 3)
  
  
  return(data.table(cond=cond_name, r2_loo = r2_cond,  r2_all= r2_all))
  
}

pretest_loo_correlations = function(hdi_data_all, experiment_data_path, hdi_data_path) {
  
  corrs = lapply(0:20, pretest_loo_correlation_for_condition, hdi_data_all=hdi_data_all, experiment_data_path=experiment_data_path, hdi_data_path=hdi_data_path)
  corr_tbl = do.call("rbind", corrs)
  return(corr_tbl)
}

post_adaptation_correlation = function(hdi_data, exp_data) {
  pred_data = hdi_data %>% 
    group_by(percentage_blue, modal, condition) %>%
    summarise(rating_pred_m = mean(rating_pred*100), 
              ci_low_pred = quantile(rating_pred*100, 0.025), 
              ci_high_pred = quantile(rating_pred*100, 0.975)) 
  pred_data$modal = factor(pred_data$modal, 
                               levels = modals, 
                               labels = modals_labels, 
                               ordered = TRUE)
  
  exp_data$pair = exp_data$condition
  exp_data = get_data_for_plotting(exp_data)
  exp_data$condition = exp_data$pair
  merged_data = merge(pred_data, exp_data, by=c("percentage_blue", "modal", "condition"))
  model = lm(rating_pred_m ~ rating_m, data=merged_data)
  r2 = round(summary(model)$r.squared, 3)
  return(r2)
  
}
