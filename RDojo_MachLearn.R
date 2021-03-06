# Created by Rick Pack and Chad Himes during the Triangle .NET User Group 
#   "Introduction to R" dojo, led by 
#   Kevin Feasel and Jamie Dixon.
# Vast majority of code from the tutorial by Jason Brownlee:
# "Your First Machine Learning Project in R 
#   Step-By-Step (tutorial and template for future projects)"
#    http://machinelearningmastery.com/machine-learning-in-r-step-by-step/
# Added code starts at line 63
install.packages("caret")
install.packages("caret", dependencies=c("Depends", "Suggests"))
install.packages("ellipse", dependencies = TRUE)
library(caret)
library(ellipse)
# attach the iris dataset to the environment
data(iris)
# rename the dataset
dataset <- iris
# create a list of 80% of the rows in the original dataset we can use for training
validation_index <- createDataPartition(dataset$Species, p=0.80, list=FALSE)
# select 20% of the data for validation
validation <- dataset[-validation_index,]
# use the remaining 80% of data to training and testing the models
dataset <- dataset[validation_index,]
# split input and output
# 5th column is outcome variable "Species"
# 1-4th are two types of length and width measurements
x <- dataset[,1:4]
y <- dataset[,5]
# scatterplot matrix
# Scatterplot shows overlap of green (species "virginica") 
#   and pink (species "versicolor")
featurePlot(x=x, y=y, plot="ellipse")

control <- trainControl(method="cv", number=10)
metric <- "Accuracy"
# a) linear algorithms
set.seed(7)
fit.lda <- train(Species~., data=dataset, method="lda", metric=metric, trControl=control)
# b) nonlinear algorithms
# CART
set.seed(7)
fit.cart <- train(Species~., data=dataset, method="rpart", metric=metric, trControl=control)
# kNN
set.seed(7)
fit.knn <- train(Species~., data=dataset, method="knn", metric=metric, trControl=control)
# c) advanced algorithms
# SVM
set.seed(7)
fit.svm <- train(Species~., data=dataset, method="svmRadial", metric=metric, trControl=control)
# Random Forest
set.seed(7)
fit.rf <- train(Species~., data=dataset, method="rf", metric=metric, trControl=control)

# summarize accuracy of models
results <- resamples(list(lda=fit.lda, cart=fit.cart, knn=fit.knn, svm=fit.svm, rf=fit.rf))
summary(results)

# estimate skill of LDA on the validation dataset
# Shows accuracy is 100% (1) for validation dataset
predictions <- predict(fit.lda, validation)
confusionMatrix(predictions, validation$Species)

# NEW: Evaluating performance on the training dataset, which has 80% of records
#  Jason's code above showed that linear discriminant analysis performed best,
#   but what we can we learn about the incorrectly predicted flowers?
# Assign former "dataset" to trainset to make clear its identity
trainset <- dataset
trainset$predictionsT <- predict(fit.lda, trainset)
trainset$y2 <- ifelse (trainset$Species == trainset$predictionsT, trainset$Species, "mismatch")
# split input and output
x2 <- trainset[,1:4]
# y has to be a factor or featurePlot crashes (returns NULL)
y2 <- as.factor(trainset$y2)
# report details about mismatches
trainset[trainset$y2=="mismatch",]
# Scatterplot matrix with a the mismatches in red.
#  As expected, the mismatches appear in the intersection of
#   green (species "virginica") and pink (species "versicolor")
featurePlot(x=x2, y=y2, plot="ellipse")
