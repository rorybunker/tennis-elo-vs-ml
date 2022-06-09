# The Elo and WElo ratings are set to 1500 for each player at the beginning of the sample. 
# The initial period from 2005 to 2011 is used as burn-in to predict (one-step-ahead) 
# the winning probabilities for the matches played in the first competing day of 2012 ATP tour. 
# For each of the following days, the information set is updated with the results 
# of the matches played in the previous day. 
# Then, each model is re-estimated to obtain the winning probabilities for the 
# matches scheduled for the following day. 
# This procedure is repeated until the end of the sample. In other words, we 
# achieve the one-step-ahead forecasts for the matches played at time t + 1 conditional 
# on the information set up to day t, for the out-of-sample period from 2012 to 2020. 
# For comparison purposes, we evaluate the forecasting performances year-by-year 
# and for the full out-of- sample period.

library(welo)

#load data
load("/Users/rorybunker/Google Drive/Research/Tennis Prediction ML/data/Vincenzo Data/WElo supplementary material/atp_2005_2020.RData") 
#clean data
Data_Clean <- clean(data.frame(db))
#convert date column string to date
Data_Clean$Date <- as.Date(Data_Clean$Date, "%d/%m/%Y")

correctPredictionsElo <- c()
incorrectPredictionsElo <- c()
correctPredictionsWElo <- c()
incorrectPredictionsWElo <- c()
latest_date <- as.Date("2012-01-01")
first_date <- min(Data_Clean$Date) #"2005-07-05"

while (latest_date <= as.Date("2012-12-31")) {
  test <- Data_Clean[Data_Clean$Date == latest_date,]
  
  if (nrow(test) > 0) {
    train <- Data_Clean[Data_Clean$Date >= first_date &
                          Data_Clean$Date < latest_date,]
    res <- welofit(train)
    res_ld <- welofit(res, new_data = test)
    results_final <- res_ld[["dataset"]]
    
    results_final_test <-
      results_final[results_final$Date == latest_date,]
    
    results_final_test$predictedWinnerWElo <-
      ifelse((results_final_test$WElo_pi_hat > (1-results_final_test$WElo_pi_hat)),
             results_final_test$P_i,
             results_final_test$P_j
      )
    
    results_final_test$predictedWinnerElo <-
      ifelse((results_final_test$Elo_pi_hat > (1-results_final_test$Elo_pi_hat)),
             results_final_test$P_i,
             results_final_test$P_j
      )
    
    results_final_test$correctPredictionWElo <-
      ifelse((
        results_final_test$predictedWinnerWElo == results_final_test$Winner
      ),
      1,
      0)
    
    results_final_test$correctPredictionElo <-
      ifelse((
        results_final_test$predictedWinnerElo == results_final_test$Winner
      ),
      1,
      0)

    #append latest accuracy figure
    correctPredictionsElo <- c(correctPredictionsElo, sum(results_final_test$correctPredictionElo))
    incorrectPredictionsElo <- c(incorrectPredictionsElo, length(results_final_test$correctPredictionElo)-sum(results_final_test$correctPredictionElo))
    
    correctPredictionsWElo <- c(correctPredictionsWElo, sum(results_final_test$correctPredictionWElo))
    incorrectPredictionsWElo <- c(incorrectPredictionsWElo, length(results_final_test$correctPredictionWElo)-sum(results_final_test$correctPredictionWElo))
  }
  latest_date = latest_date + 1
}

EloAccuracy <- sum(correctPredictionsElo)/(sum(incorrectPredictionsElo)+sum(correctPredictionsElo))
EloAccuracy
WEloAccuracy <- sum(correctPredictionsWElo)/(sum(incorrectPredictionsWElo)+sum(correctPredictionsWElo))
WEloAccuracy
