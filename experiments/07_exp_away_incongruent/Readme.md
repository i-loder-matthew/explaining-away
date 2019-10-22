# Explaining away effects and semantic adaptation: Incongruent conditions

We investigate how much listeners adapt to variable use of uncertainty expressions  such as _might_ and _probably_ in different contexts. In particular, we ask whether there is a consistent relationship between surprisal of observed interactions and adaptation, such that listeners adapt more if the speaker's language use is unexpected.

Each participant sees a pair of speakers, a customer and an airline representative, along with a seat map demonstrating the probability of a certain outcome. In the first part of the experiment, the exposure phase, the participant is asked to look at the seat map and listen carefully to a recording of the airline representative responding to a customer's request.


In this experiment, there are two conditions: _optimist-incongruent_ and _pessimist-incongruent_.  In the pessimist condition, participants are told that the airline representative is in a particularly bad mood that day. Likewise, in the optimist condition,  participants are told that the airline representative is in a particularly good mood. In the second part of the experiment, the participant is asked to respond to the customer as they think the flight attendant would. The participants are asked to rate each of the pair of responses based on how likely they think it is that they would use a particular uncertainty expression.

## Participants

MTurk participants with US IP addresses and >95% approval. In total we collect data from 160 particpants (80 per condition).

## Exclusion Criteria

We exclude participants who seem to provide random ratings independent of the scene that they are seeing. We quantify this by computing the mean rating for each utterance across all trials for each participant and computing the correlation between a participant's actual ratings and their mean rating. A high correlation is unexpected and indicates that a participant chose ratings at random. We therefore also exclude the data from participants for whom this correlation is larger than 0.75.

## Procedure

See the following web-based experiments:

Condition _optimist-incongruent_:
https://i-loder-matthew.github.io/explaining-away/experiments/07_exp_away_incongruent/experiment/cond-5

Condition _pessimist-incongruent_:
https://i-loder-matthew.github.io/explaining-away/experiments/07_exp_away_incongruent/experiment/cond-6

## Predictions

We compare the difference in AUC between the _might_ ratings and the _probably_ ratings across these two conditions, and then compare the effect size to the 
effect size of a baseline experiment to the "cautious-confident" effect from a [previous experiment](../04_exp_away). We expect the effect size to be bigger
in this experiment than in the baseline experiment.

## Analysis

See [analysis/Analysis.Rmd](analysis/Analysis.Rmd) for the exact analysis procedures.


