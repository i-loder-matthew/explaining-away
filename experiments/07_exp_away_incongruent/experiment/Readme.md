# Explaining away effects and semantic adaptation

Each participant sees a pair of speakers, a customer and an airline representative, along with a seat map demonstrating the probability of a certain outcome. In one condition, the participant is asked to respond as an optimistic airline representative would. In the other, the particiapnt is asked to respond as a pessimistic airline attendant would. The participants are asked to rate each of the pair of responses based on how likely they think it is that they would use a particular uncertainty expression.

## Participants

MTurk participants with US IP addresses and >95% approval. In total we collect data from 40 particpants.

## Exclusion Criteria

We exclude participants who seem to provide random ratings independent of the scene that they are seeing. We quantify this by computing the mean rating for each utterance across all trials for each participant and computing the correlation between a participant's actual ratings and their mean rating. A high correlation is unexpected and indicates that a participant chose ratings at random. We therefore also exclude the data from participants for whom this correlation is larger than 0.75.


## Procedure

See the following web-based experiments:

Condition 1:
https://i-loder-matthew.github.io/explaining-away/experiments/02_norming/experiment/experiment-cond-1

Condition 2:
https://i-loder-matthew.github.io/explaining-away/experiments/02_norming/experiment/experiment-cond-2


## Predictions

We predict that the difference in AUC between the might ratings and the probably ratings will be significantly higher when the speakers are providing ratings for a pessimistic context than when they are providing ratings for an optimistic context.  

## Analysis

See analysis/analysis.Rmd for the exact analysis procedures.

## Pilot

Prior to this study we conducted a pilot with 20 total participants, or 10 participants in each condition. Based on the performance in the pilot, which led to significant results, we have decided to go ahead with the actual experiment. 
