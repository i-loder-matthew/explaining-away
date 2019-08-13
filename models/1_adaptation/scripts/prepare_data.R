library(dplyr)

format_data = function(d) {
  
  d_window = d %>% filter(., grepl("window", type))
  d_aisle = d %>% filter(., grepl("aisle", type))
  
  d_aisle_reverse = d_aisle
  d_aisle_reverse$percent_window = 100-d_aisle$percent_window
  
  d = rbind(d_window, d_aisle_reverse)
  colnames(d)[colnames(d)=="percent_window"] <- "percentage_blue"
  
  return(d)
}

d1 = format_data(read.csv("~/Documents/research/explaining-away/experiments/02_norming/data/02_norming_cond1-trials.csv"))
d2 = format_data(read.csv("~/Documents/research/explaining-away/experiments/02_norming/data/02_norming_cond2-trials.csv"))

d1$condition = "optimist"
d2$condition = "pessimist"

d2$workerid = max(d1$workerid) + 1 + d2$workerid

d = rbind(d1, d2)

d = d[rep(1:nrow(d), 10), ]

d_obs = d %>%
  rowwise() %>%
  mutate(rating1 = max(0, rating1), rating2 = max(0, rating2), rating_other = max(0, rating_other))

d_obs = d_obs %>%
  rowwise() %>%
  mutate(modal = sample(c("probably", "might", "other" ), prob = c(rating1, rating2, rating_other), size=1))

drops <- c("sentence1", "sentence2")
d_obs = d_obs[ , !(names(d_obs) %in% drops)]

data.optimist = list(obs = d_obs %>% filter(condition == "optimist"))
data.pessimist = list(obs = d_obs %>% filter(condition == "pessimist"))

data_string = jsonlite::toJSON(data.optimist, digits=NA)
cat(data_string, file = "~/Documents/research/semantic-adaptation/adaptation/models/2_adaptation_model/data/speaker_adaptation_optimist.json")
data_string = jsonlite::toJSON(data.pessimist, digits=NA)
cat(data_string, file = "~/Documents/research/semantic-adaptation/adaptation/models/2_adaptation_model/data/speaker_adaptation_pessimist.json")

# another one down and another one down, another one bites the dust

d1 = read.csv("~/Documents/research/explaining-away/experiments/04_exp_away/data/04_exp_away_cond2-trials.csv")
d1 = format_data(d1)
d2 = format_data(read.csv("~/Documents/research/explaining-away/experiments/04_exp_away/data/04_exp_away_cond3-trials.csv"))
d3 = format_data(read.csv("~/Documents/research/explaining-away/experiments/04_exp_away/data/04_exp_away_cond4-trials.csv"))

d1$Answer.condition = "confident"
d2$Answer.condition = "pessimist"
d3$Answer.condition = "cautious"

d2$workerid = max(d1$workerid) + 1 + d2$workerid
d3$workerid = max(d2$workerid) + 1 + d3$workerid

d = rbind(d1, d2, d3)

d = d[rep(1:nrow(d), 10), ]

d_obs = d %>%
  rowwise() %>%
  mutate(rating1 = max(0, rating1), rating2 = max(0, rating2), rating_other = max(0, rating_other))

d_obs = d_obs %>%
  rowwise() %>%
  mutate(modal = sample(c("probably", "might", "other" ), prob = c(rating1, rating2, rating_other), size=1))

drops <- c("sentence1", "sentence2")
d_obs = d_obs[ , !(names(d_obs) %in% drops)]

data.confident = list(obs = d_obs %>% filter(Answer.condition == "confident"))
data.pessimist = list(obs = d_obs %>% filter(Answer.condition == "pessimist"))
data.cautious = list(obs = d_obs %>% filter(Answer.condition == "cautious"))

data_string = jsonlite::toJSON(data.confident, digits=NA)
cat(data_string, file = "~/Documents/research/semantic-adaptation/adaptation/models/2_adaptation_model/data/speaker_adaptation_confident_main.json")
data_string = jsonlite::toJSON(data.pessimist, digits=NA)
cat(data_string, file = "~/Documents/research/semantic-adaptation/adaptation/models/2_adaptation_model/data/speaker_adaptation_pessimist_main.json")
data_string = jsonlite::toJSON(data.cautious, digits=NA)
cat(data_string, file = "~/Documents/research/semantic-adaptation/adaptation/models/2_adaptation_model/data/speaker_adaptation_cautious_main.json")




# balanced
d_blue = d.rep %>% filter(., grepl("blue", sentence2))
d_orange = d.rep %>% filter(., grepl("orange", sentence2))

d_orange_reverse = d_orange
d_orange_reverse$percentage_blue = 100-d_orange$percentage_blue

d.rep = rbind(d_blue, d_orange_reverse)

d.rep = 

d = d.rep[rep(1:nrow(d.rep), 10), ]

counter = 0
d_obs1 = d %>%
  rowwise() %>%
  mutate(rating1 = max(0, rating1), rating2 = max(0, rating2), rating_other = max(0, rating_other))


d_obs = d_obs1 %>%
  rowwise() %>%
  mutate(modal = sample(c("might", "probably", "other" ), prob = c(rating1, rating2, rating_other), size=1))
  

drops <- c("sentence1", "sentence2")
d_obs = d_obs[ , !(names(d_obs) %in% drops)]

data.cautious = list(obs = d_obs %>% filter(condition == "cautious speaker"))
data.confident = list(obs = d_obs %>% filter(condition == "confident speaker"))

data_string = jsonlite::toJSON(data.cautious, digits=NA)
cat(data_string, file = "/Users/sebschu/Dropbox/Uni/RA/adaptation/adaptation/models/2_adaptation_model/data/speaker_adaptation_balanced_cautious.json")
data_string = jsonlite::toJSON(data.confident, digits=NA)
cat(data_string, file = "/Users/sebschu/Dropbox/Uni/RA/adaptation/adaptation/models/2_adaptation_model/data/speaker_adaptation_balanced_confident.json")
