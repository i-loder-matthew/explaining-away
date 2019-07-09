# Explaining away effects and semantic adaptation

Each participant sees a pair of speakers, a customer and an airline attendant, along with a seat map demonstrating the probability of a certain outcome. In some situations, the participant sees a pair of responses connected to a desired outcome for the customer, and in other cases, to an undesired outcome. The participants are asked to rate each of the pair of responses based on how likely they think it is that they would use a particular uncertainty expression.

## Participants

MTurk participants with US IP addresses and >95% approval. In total we collect data from 80 particpants.

## Exclusion Criteria

We exclude participants who seem to provide random ratings independent of the scene that they are seeing. We quantify this by computing the mean rating for each utterance across all trials for each participant and computing the correlation between a participant's actual ratings and their mean rating. A high correlation is unexpected and indicates that a participant chose ratings at random. We therefore also exclude the data from participants for whom this correlation is larger than 0.75.


## Procedure

See the following web-based experiment:

https://i-loder-matthew.github.io/explaining-away/experiments/01_norming_study/experiment


## Predictions

We predict that the difference in AUC between the might ratings and the probably ratings will be significantly higher when the speakers are providing ratings for a positive context than when they are providing ratings for a negative context.  

## Analysis

See analysis/analysis.Rmd for the exact analysis procedures.
