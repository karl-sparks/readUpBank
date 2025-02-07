#' Get UP Bank Auth token
#'
#'  Will retrieve the auth token called `UP_TOKEN`. It will look for the token from the following places in order:
#'   1. R Option
#'   2. Sys environment
#'   3. .env file
#'
#'  `get_up_bank_auth_token()` will display a warning if the token hasn't been set up.
#'
#' @return UP Bank Auth Token
get_up_bank_auth_token <- function() {
  token <- getOption("UP_TOKEN", default = get_up_bank_auth_token_from_sys_env())

  if (token == "") {
    cli::cli_warn(
      "Can not find UP Bank authentication token. Set up a .env or environment variable with the token saved as: `UP_TOKEN`"
    )
  }

  token
}

#' @rdname get_up_bank_auth_token
get_up_bank_auth_token_from_sys_env <- function() {
  Sys.getenv("UP_TOKEN", unset = get_up_bank_auth_token_from_dotenv())
}


#' @rdname get_up_bank_auth_token
get_up_bank_auth_token_from_dotenv <- function() {
  suppressWarnings(
    readRenviron(".env") # this will throw a warning if no .env. We check for this explicitly in a parent function and it makes it clearer if we suppress this.
  )
  Sys.getenv("UP_TOKEN")
}
