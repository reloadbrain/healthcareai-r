context("checking untuned models")

set.seed(2057)
dd <- na.omit(pima_diabetes)[51:100, ]
cl <- dd %>%
  prep_data(patient_id, outcome = diabetes) %>%
  flash_models(diabetes)
reg <- dd %>%
  prep_data(patient_id, outcome = age) %>%
  flash_models(age)

test_that("flash_models returns appropriate model_list", {
  expect_s3_class(cl, "model_list")
  expect_s3_class(cl, "classification_list")
  expect_s3_class(reg, "model_list")
  expect_s3_class(reg, "regression_list")
})

test_that("flash_models let's user select model", {
  expect_error(flash_models(dd, diabetes, models = "rf"), NA)
  expect_error(flash_models(dd, diabetes, models = "knn"), NA)
})

test_that("flash_models errors informatively if hyperparameters and models don't match", {
  expect_error(flash_models(dd, diabetes,
                            hyperparameters = get_hyperparameter_defaults("knn")),
               "knn")
  expect_error(flash_models(dd, diabetes, models = "rf",
                            hyperparameters = get_hyperparameter_defaults("knn")),
               "rf")
})

test_that("flash_models works on prepped data", {
  pd <- prep_data(pima_diabetes, patient_id, outcome = diabetes)
  m <- flash_models(pd, diabetes)
})

test_that("flash_models are model_lists with attr tuned = FALSE", {
  expect_false(attr(cl, "tuned"))
  expect_true(is.model_list(cl))
})

test_that("can predict on flash models", {
  expect_s3_class(predict(cl), "hcai_predicted_df")
  expect_s3_class(predict(reg, dd[10:1, ]), "hcai_predicted_df")
})