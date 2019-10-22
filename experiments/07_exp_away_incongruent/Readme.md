# Explaining away effects and semantic adaptation

Each participant sees a pair of speakers, a customer and an airline representative, along with a seat map demonstrating the probability of a certain outcome. In the first part of the experiment, the exposure phase, the participant is asked to look at the seat map and listen carefully to a recording of the airline representative responding to a customer's request. This experiment (optimist-c) are a follow-up to an identical version of the experiment run with three conditions (pessimist, cautious, confident). In the cautious and pessimistic conditions the speakers see the same language usage, but the pessimistic speaker is told that the airline representative is in a particularly bad mood that day. Likewise, in the optimistic and confident condition, participants see the exact same language usage, but in the optimistic condition, the listener is told that the airline representative is in a particularly good mood. In the second part of the experiment, the participant is asked to respond to the customer as they think the flight attendant would. The participants are asked to rate each of the pair of responses based on how likely they think it is that they would use a particular uncertainty expression.

## Participants

MTurk participants with US IP addresses and >95% approval. In total we collect data from 160 particpants.

## Exclusion Criteria

We exclude participants who seem to provide random ratings independent of the scene that they are seeing. We quantify this by computing the mean rating for each utterance across all trials for each participant and computing the correlation between a participant's actual ratings and their mean rating. A high correlation is unexpected and indicates that a participant chose ratings at random. We therefore also exclude the data from participants for whom this correlation is larger than 0.75.

## Procedure

See the following web-based experiments:

Condition 1:
https://i-loder-matthew.github.io/explaining-away/experiments/06_exp_away/experiment/cond-1

## Predictions

We compare the difference in AUC between the might ratings and the probably ratings to the ratings from the "confident speaker" condition from a previous experiment. Based on a  pilot study, we expect the difference in this "optimistic" condition to be qualitatively smaller than or equal to the difference in the "confident speaker" condition of the previous experiment.  

## Analysis

See analysis/analysis.Rmd for the exact analysis procedures.

## Pilot

We conducted a pilot with 40 total participants (10 in each of four conditions). On the basis of the performance in the pilot, we had initially decided to proceed with the experiment in only three of the original four conditions. In this experiment, we collect data for the fourth condition, which we omitted in the previous experiment.

## An Earlier Experiment

We are running this condition as a follow up to an earlier experiment run with just three conditions. See the following link to that experiment: https://github.com/i-loder-matthew/explaining-away/tree/master/experiments/04_exp_away

In that experiment, we compared the cautious and confident conditions to one another to demonstrate adaptation effects, and the pessimistic and cautious conditions to demonstrate explaining away. In this experiment then, we will explore the difference between the AUCs for the optimistic condition and the confident condition, to see how much adaptation happens there as well. 
