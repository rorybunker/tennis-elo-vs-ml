library(welo)

#load data
load("atp_2005_2020.RData") 
#clean data
Data_Clean <- clean(data.frame(db))
#convert date column string to date
Data_Clean$Date <- as.Date(Data_Clean$Date, "%d/%m/%Y")
#get first and last dates in the dataset
first_date <- min(Data_Clean$Date) #"2005-07-05"
last_date <- max(Data_Clean$Date)
#create training and test sets
train <- Data_Clean[Data_Clean$Date >= first_date &
                      Data_Clean$Date < "2019-12-31",]

test <- Data_Clean[Data_Clean$Date >= "2020-01-01" &
                     Data_Clean$Date < last_date,]
#percentage of dataset that is training
train_perc <- length(train$ID)/(length(test$ID)+length(train$ID))

#fit WElo to training dataset
res <- welofit(train)
#apply trained WElo model to test dataset
res_ld <- welofit(res, new_data = test)

results_final <- res_ld[["dataset"]]

results_final_test <- results_final[results_final$Date >= "2020-01-01" & 
                                      results_final$Date < last_date,]

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

train_perc
EloAccuracy <- sum(correctPredictionsElo)/(sum(incorrectPredictionsElo)+sum(correctPredictionsElo))
EloAccuracy
WEloAccuracy <- sum(correctPredictionsWElo)/(sum(incorrectPredictionsWElo)+sum(correctPredictionsWElo))
WEloAccuracy
