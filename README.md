# Comparing Elo Ratings- with Machine Learning-based Methods for Tennis Match Result Prediction

The atp_2005_2020.RData and wta_2007_2020.RData datasets are the ATP and WTA datasets used by Angelini, Candila & De Angelis (2022), which were originally sourced from tennis-data.co.uk.

This study (Bunker et al., 2022) considers only ATP (men's).

Data_Clean.csv is just the atp_2005_2020.RData dataset passed through the clean() function in Angelini et al.'s welo R package (https://cran.r-project.org/web/packages/welo/index.html).

# Usage
To run the script, simply set the train_start_date, train_end_date, and test_end_date dates (test_start_date is set to be one day after train_end_date).

The dataset atp_2005_2020.RData must be in the same directory as the R script.

For example, to calculate the accuracy of Elo and WElo for training set 2007 to 2019 and test set 2020:
```
train_start_date <- "2007-01-01"
train_end_date <- "2019-12-31"
test_end_date <- "2020-12-31"
```

## References
Angelini, G., Candila, V., & De Angelis, L. (2022). Weighted Elo rating for tennis match predictions. European Journal of Operational Research, 297(1), 120-132. https://doi.org/10.1016/j.ejor.2021.04.011

Bunker, R., Yeung, C.K., Susnjak, T., Espie, C., & Fujii, K. (2022). Comparing Elo Ratings- with Machine Learning-based Methods for Tennis Match Result Prediction. Working Paper.
