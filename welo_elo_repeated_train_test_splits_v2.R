library(welo)

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

train <- Data_Clean[Data_Clean$Date >= first_date & Data_Clean$Date <= end_date,]
res <- welofit(train)

results = res[["dataset"]]
results_final = results[results$Date >= test_date & results$Date <= end_date,]
results_final_test=results_final

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

EloAccuracy <- sum(correctPredictionsElo)/(sum(incorrectPredictionsElo)+sum(correctPredictionsElo))
print(c("Elo",EloAccuracy))
WEloAccuracy <- sum(correctPredictionsWElo)/(sum(incorrectPredictionsWElo)+sum(correctPredictionsWElo))
print(c("Welo",WEloAccuracy))
