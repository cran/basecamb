#' Build formula for statistical models
#'
#' Build formula used in statistical models from vectors of strings with the option to specify an environment.
#'
#' @param outcome character denoting the column with the outcome.
#' @param predictors vector of characters denoting the columns with the
#'   predictors.
#' @param censor_event character denoting the column with the censoring event,
#'   for use in Survival-type models.
#' @param env environment to be used in formula creation
#'
#' @return formula for use in statistical models
#'
#' @examples
#' build_model_formula("outcome", c("pred_1", "pred_2"))
#' build_model_formula("outcome", c("pred_1", "pred_2"), censor_event = "cens_event")
#'
#' @importFrom assertthat is.string
#'
#' @export
#'
#' @author J. Peter Marquardt
build_model_formula <- function(outcome, predictors, censor_event=NULL, env = parent.frame()) {

  assertthat::is.string(outcome)
  assertthat::is.string(predictors)


  if(is.null(censor_event)) {  # standard formula
    frml <- as.formula(paste(outcome,
                             ' ~ ',
                             paste(predictors, collapse = ' + '),
                             sep = ''),
                       env = env
    )
  }

  else {  # Survival-type formula
    assertthat::is.string(censor_event)
    frml <- as.formula(paste('Surv(',
                             outcome,
                             ', ',
                             censor_event,
                             ')~',
                             paste(predictors, collapse = ' + '),
                             sep = ''),
                       env = env
    )
  }

  return(frml)
}


#' Deconstruct formula
#'
#' Deconstruct a formula object into strings of its components. Predictors are
#'   split by '+', so interaction terms will be returned as a single string.
#'
#' @param formula formula object for use in statistical models.
#'
#' @return a named list with fields:
#'
#' * outcome (character)
#' * predictors (vector of characters)
#' * censor_event (character) (optional) censor event, only for formulas including a Surv() object
#'
#' @examples
#' deconstruct_formula(stats::as.formula("outcome ~ predictor1 + predictor2 + predictor3"))
#' deconstruct_formula(stats::as.formula("Surv(outcome, censor_event) ~ predictor"))
#'
#' @importFrom assertthat assert_that
#' @importFrom stats as.formula
#'
#' @export
#'
#' @author J. Peter Marquardt
deconstruct_formula <- function(formula){

  assertthat::assert_that("formula" %in% class(formula))

  # deparsing formula into string with no spaces and newlines
  form_string <- gsub(' ', '', gsub('\n', '', deparse1(formula, collapse = '')))

  # extracting components
  if(substr(form_string, 1, 5) == 'Surv(') {  # Survival formula
    surv_string <- strsplit(form_string, ')')[[1]][1]  # Extracting the Surv() part of it
    surv_params <- strsplit(substr(surv_string, 6, nchar(surv_string)), ',')  # extracting everything inside the Surv()
    outcome <- surv_params[[1]][1]  # assigning time variable name
    censor_event <- surv_params[[1]][2]  # assigning cens variable name
  }
  else {  # ordninary formula
    outcome <- strsplit(form_string, '~')[[1]][1]
    censor_event <- NULL
  }
  predictors <- strsplit(strsplit(form_string, '~')[[1]][2], split='+', fixed = TRUE)[[1]] # same for all

  # assembling output list
  component_list <- list('outcome' = outcome,
                         'predictors' = predictors)
  if(!is.null(censor_event)) {component_list$`censor_event` <- censor_event}

  return(component_list)
}
