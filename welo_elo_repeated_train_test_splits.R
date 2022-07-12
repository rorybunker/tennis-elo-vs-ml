# Procedure: The Elo and WElo ratings are set to 1500 for each player at the beginning of the sample. 
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

# load data
load("/Users/rorybunker/Google Drive/Research/Tennis Prediction ML/data/Vincenzo Data/WElo supplementary material/atp_2005_2020.RData") 
# clean data
Data_Clean <- clean(data.frame(db))
# convert date column string to date
Data_Clean$Date <- as.Date(Data_Clean$Date, "%d/%m/%Y")
# create result vectors to be appended to
correctPredictionsElo <- c()
incorrectPredictionsElo <- c()
correctPredictionsWElo <- c()
incorrectPredictionsWElo <- c()

test_date <- as.Date("2012-01-01")
# fixed at the first date in the dataset "2005-07-05":
first_date <- min(Data_Clean$Date) 
# desired end of out-of-sample period
end_date = as.Date("2012-12-31")

while (test_date <= end_date) {
  date_diff <- difftime(test_date, end_date)
  print(date_diff)
  
  test <- Data_Clean[Data_Clean$Date == test_date,]
  
  # if there are no matches for this test_date, continue to next date
  if (nrow(test) == 0) {
    test_date = test_date + 1
    next
  }
  
  else if (nrow(test) > 0) {
    print(test_date)
    train <- Data_Clean[Data_Clean$Date >= first_date &
                          Data_Clean$Date < test_date,]
    res <- welofit(train)
    res_ld <- welofit(res, new_data = test)
    
    results_final <- res_ld[["dataset"]]
    
    # 1-day test set
    results_final_test <- results_final[results_final$Date == test_date,]
    
    # predicted winner based on the players' WElo ratings
    results_final_test$predictedWinnerWElo <-
      ifelse((results_final_test$WElo_pi_hat > (1-results_final_test$WElo_pi_hat)),
             results_final_test$P_i,
             results_final_test$P_j
      )
    # predicted winner based on the players' Elo ratings
    results_final_test$predictedWinnerElo <-
      ifelse((results_final_test$Elo_pi_hat > (1-results_final_test$Elo_pi_hat)),
             results_final_test$P_i,
             results_final_test$P_j
      )
    # binary variable that takes the value 1 if the WElo prediction was correct; 0 otherwise
    results_final_test$correctPredictionWElo <-
      ifelse((
        results_final_test$predictedWinnerWElo == results_final_test$Winner
      ),
      1,
      0)
    # binary variable that takes the value 1 if the Elo prediction was correct; 0 otherwise
    results_final_test$correctPredictionElo <-
      ifelse((
        results_final_test$predictedWinnerElo == results_final_test$Winner
      ),
      1,
      0)
    
    # append latest accuracy figures to the results vectors
    correctPredictionsElo <- c(correctPredictionsElo, sum(results_final_test$correctPredictionElo))
    incorrectPredictionsElo <- c(incorrectPredictionsElo, length(results_final_test$correctPredictionElo)-sum(results_final_test$correctPredictionElo))
    
    correctPredictionsWElo <- c(correctPredictionsWElo, sum(results_final_test$correctPredictionWElo))
    incorrectPredictionsWElo <- c(incorrectPredictionsWElo, length(results_final_test$correctPredictionWElo)-sum(results_final_test$correctPredictionWElo))
    
    test_date = test_date + 1
  }
}
# calculate and print final accuracy results
EloAccuracy <- sum(correctPredictionsElo)/(sum(incorrectPredictionsElo)+sum(correctPredictionsElo))
print(EloAccuracy)
WEloAccuracy <- sum(correctPredictionsWElo)/(sum(incorrectPredictionsWElo)+sum(correctPredictionsWElo))
print(WEloAccuracy)
