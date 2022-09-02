library(welo)

#load data
load("atp_2005_2020.RData") 
#clean data
Data_Clean <- clean(data.frame(db))
#convert date column string to date
Data_Clean$Date <- as.Date(Data_Clean$Date, "%d/%m/%Y")

train_start_date <- "2006-01-01" #min(Data_Clean$Date)
train_end_date <- "2019-12-31"
test_start_date <- as.Date(train_end_date) + 1
test_end_date <- "2020-12-31" #max(Data_Clean$Date) # max(Data_Clean$Date)

#create training and test sets
train <- Data_Clean[Data_Clean$Date >= train_start_date &
                      Data_Clean$Date < train_end_date,]

test <- Data_Clean[Data_Clean$Date >= test_start_date &
                     Data_Clean$Date < test_end_date,]

#percentage of dataset that is training
train_perc <- length(train$ID)/(length(test$ID)+length(train$ID))

#fit WElo to training dataset
res <- welofit(train)
#apply trained WElo model to test dataset
res_ld <- welofit(res, new_data = test)

results_final <- res_ld[["dataset"]]

results_final_test <- results_final[results_final$Date >= test_start_date & 
                                      results_final$Date < test_end_date,]

#determine whether prediction was correct or incorrect, and calculate accuracies of Elo and WElo
results_final_test$predictedWinnerElo <-
  ifelse((results_final_test$Elo_pi_hat > (1-results_final_test$Elo_pi_hat)),
         results_final_test$P_i,
         results_final_test$P_j
  )

results_final_test$predictedWinnerWElo <-
  ifelse((results_final_test$WElo_pi_hat > (1-results_final_test$WElo_pi_hat)),
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

correctPredictionsElo <- sum(results_final_test$correctPredictionElo)
incorrectPredictionsElo <- length(results_final_test$correctPredictionElo)-sum(results_final_test$correctPredictionElo)

correctPredictionsWElo <- sum(results_final_test$correctPredictionWElo)
incorrectPredictionsWElo <- length(results_final_test$correctPredictionWElo)-sum(results_final_test$correctPredictionWElo)

print(train_perc)
EloAccuracy <- sum(correctPredictionsElo)/(sum(incorrectPredictionsElo)+sum(correctPredictionsElo))
EloAccuracy*100
WEloAccuracy <- sum(correctPredictionsWElo)/(sum(incorrectPredictionsWElo)+sum(correctPredictionsWElo))
WEloAccuracy*100
