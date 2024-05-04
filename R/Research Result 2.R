#### Script Settings and Resources ####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(haven)
library(caret)

set.seed(123)

#### Data Import and Cleaning #### 
# Import original data
Wave2_ori_tbl_ML <- read_tsv("../data/HCCP_2ndWave_Work_2nd.txt")

# Create a Wave2_tbl_ML by cleanning data
Wave2_tbl_ML <- Wave2_ori_tbl_ML %>%
  select(W21Q26A, W21Q26B, W21Q26C, W21Q25D, W21Q25E, W21Q25F) %>%
  rowwise() %>%
  mutate(job_satis = mean(c(W21Q26A, W21Q26B, W21Q26C))) %>%
  mutate(clan_culture = mean(c(W21Q25D, W21Q25E, W21Q25F)))


#### Analysis #### 
## Prepare data set to run ML ##
# Create sample rows  
Wave2_sample <- sample(nrow(Wave2_tbl_ML))
# Shuffle using the sampled indices 
Wave2_shuffled <- Wave2_tbl_ML[Wave2_sample,]
# Calculate the number of rows for a 75/25 split
Wave2_75per <- round(nrow(Wave2_shuffled) * 0.75)
# Create the training set using the first 75% of the shuffled data
Wave2_train <- Wave2_shuffled[1:Wave2_75per,]
# Create the test set using the remaining 25% of the shuffled data
Wave2_test <- Wave2_shuffled[(Wave2_75per + 1):nrow(Wave2_shuffled), ]
# Create 10 folds for cross-validation using the job_satis column from the training set
Wave2_folds <- createFolds(Wave2_train$job_satis, 10)
# Set up train control for all model
train_control <- trainControl(method = "cv", 
                              number = 10, 
                              index = Wave2_folds, 
                              verboseIter = TRUE)


## OLS model ##
# Train the OLS regression model using train
model_OLS <- train(
  job_satis ~ .,
  data = Wave2_train,
  method = "lm", 
  metric = "Rsquared",
  preProcess = "medianImpute",
  na.action = na.pass,
  trControl = train_control
)
# Make predictions using the models
OLS_predict <- predict(model_OLS, Wave2_test, na.action = na.pass)
# Calculate R-squared values for holdout CV
ho_rsq_OLS <- cor(OLS_predict, Wave2_test$job_satis)^2


## Elastic net model ##
# Train the elastic net model using train
model_elastic <- train(
  job_satis ~ .,
  data = Wave2_train,
  method = "glmnet", 
  metric = "Rsquared",
  na.action = na.pass,
  preProcess = "medianImpute",
  trControl = train_control
)
# Make predictions using the models
elastic_predict <- predict(model_elastic, Wave2_test, na.action = na.pass)
# Calculate R-squared values for holdout CV
ho_rsq_elastic <- cor(elastic_predict, Wave2_test$job_satis)^2


## Random forest model ##
# Train the random forest model using train
model_random <- train(
  job_satis ~ .,
  data = Wave2_train,
  method = "ranger", 
  metric = "Rsquared",
  na.action = na.pass,
  preProcess = "medianImpute",
  trControl = train_control
)
# Make predictions using the models
random_predict <- predict(model_random, Wave2_test, na.action = na.pass)
# Calculate R-squared values for holdout CV
ho_rsq_random <- cor(random_predict, Wave2_test$job_satis)^2


## XGB model ##
# Train the random XGB using train
model_XGB <- train(
  job_satis ~ .,
  data = Wave2_train,
  method = "xgbLinear", 
  metric = "Rsquared",
  na.action = na.pass,
  preProcess = "medianImpute",
  trControl = train_control
)
# Make predictions using the models
XGB_predict <- predict(model_XGB, Wave2_test, na.action = na.pass)
# Calculate R-squared values for holdout CV
ho_rsq_XGB <- cor(XGB_predict, Wave2_test$job_satis)^2


#### Publication #### 
# Create a tibble with the desired structure
table1_tbl <- tibble(
  algo = c("OLS Regression", "Elastic Net", "Random Forest", "eXtreme Gradient Boosting"),
  cv_rsq = c(
    format(model_OLS$results$Rsquared, nsmall = 7),
    format(max(model_elastic$results$Rsquared), nsmall = 7),
    format(max(model_random$results$Rsquared), nsmall = 7),
    format(max(model_XGB$results$Rsquared), nsmall = 7)),
  ho_rsq = c(
    format(ho_rsq_OLS, nsmall = 7),
    format(ho_rsq_elastic, nsmall = 7),
    format(ho_rsq_random, nsmall = 7),
    format(ho_rsq_XGB, nsmall = 7)
  )
)

# Print the table
print(table1_tbl)

############################

# Create holdout indices for data partitioning
holdout_indices <- createDataPartition(Wave2_tbl_ML$job_satis,
                                       p = .25,
                                       list = T)$Resample1
# Create a test set using the holdout indices
test_tbl <- Wave2_tbl_ML[holdout_indices,]
# Create a training set by excluding the holdout indices
training_tbl <- Wave2_tbl_ML[-holdout_indices,]
# Create cross-validation folds for the training data
training_folds <- createFolds(training_tbl$job_satis)


## OLS Model ## 
# Train the OLS regression model using train function
model_OLS <- train(
  job_satis ~ .,
  training_tbl,
  method="lm",
  na.action = na.pass,
  preProcess = c("center","scale","zv","nzv","medianImpute"),
  trControl = trainControl(method="cv", 
                           number=10, 
                           verboseIter=T, 
                           indexOut = training_folds)
)
# Extracting cross-validation results (R-squared) from the OLS model
cv_OLS <- model_OLS$results$Rsquared
# Evaluating the OLS model on the holdout test set
holdout_OLS <- cor(
  predict(model_OLS, test_tbl, na.action = na.pass),
  test_tbl$job_satis
)^2

## Elastic net model ## 
# Train the elastic net model using train
model_elastic <- train(
  job_satis ~ .,
  training_tbl,
  method="glmnet",
  na.action = na.pass,
  preProcess = c("center","scale","zv","nzv","medianImpute"),
  trControl = trainControl(method="cv", 
                           number=10, 
                           verboseIter=T, 
                           indexOut = training_folds)
)
# Extracting cross-validation results (R-squared) from the Elastic net model
cv_elastic <- max(model_elastic$results$Rsquared)
# Evaluating the Elastic net model on the holdout test set
holdout_elastic <- cor(
  predict(model_elastic, test_tbl, na.action = na.pass),
  test_tbl$job_satis
)^2

## Random forest model ## 
# Train the random forest model using train
model_random <- train(
  job_satis ~ .,
  training_tbl,
  method="ranger",
  na.action = na.pass,
  preProcess = c("center","scale","zv","nzv","medianImpute"),
  trControl = trainControl(method="cv", 
                           number=10, 
                           verboseIter=T, 
                           indexOut = training_folds)
)
# Extracting cross-validation results (R-squared) from the random forest model
cv_random <- max(model_random$results$Rsquared)
# Evaluating the random forest model on the holdout test set
holdout_random <- cor(
  predict(model_random, test_tbl, na.action = na.pass),
  test_tbl$job_satis
)^2

## Random XGB ##
# Train the random XGB using train
model_XGB <- train(
  job_satis ~ .,
  training_tbl,
  method="xgbLinear",
  na.action = na.pass,
  tuneLength = 1,
  preProcess = c("center","scale","zv","nzv","medianImpute"),
  trControl = trainControl(method="cv", 
                           number=10, 
                           verboseIter=T, 
                           indexOut = training_folds)
)
# Extracting cross-validation results (R-squared) from the random XGB
cv_XGB <- max(model_XGB$results$Rsquared)
# Evaluating the random XGB on the holdout test set
holdout_XGB <- cor(
  predict(model_XGB, test_tbl, na.action = na.pass),
  test_tbl$job_satis
)^2

## Summarize and Visualization  ## 
# Calculate the summary of resampling results for multiple models
summary(resamples(list(model_OLS, model_elastic, model_random, model_XGB)), metric="Rsquared")
# Visualize the resampling results for multiple models using a dotplot
dotplot(resamples(list(model_OLS, model_elastic, model_random, model_XGB)), metric="Rsquared")

table2_tbl <- data.frame(
  algo = c("OLS Regression", "Elastic Net", "Random Forest", "eXtreme Gradient Boosting"),
  cv_rsq = c(max(model_OLS$results$Rsquared), max(model_elastic$results$Rsquared), max(model_random$results$Rsquared), max(model_XGB$results$Rsquared)),
  ho_rsq = c(ho_rsq_OLS, ho_rsq_elastic, ho_rsq_random, ho_rsq_XGB)
)
table2_tbl
