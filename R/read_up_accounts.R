#' Read Up Accounts
#'
#'  This function is used to extract accounts data from the Up Bank API. It has one optional
#'
#' @param account_id Optional; account_id to request from API. If its not provided the function will return all accounts for the authenticated user.
#'
#' @return `tibble::tibble()` containing the requested accounts data
#' @export
read_up_accounts <- function(account_id = NULL, account_type = c("SAVER", "TRANSACTIONAL", "HOME_LOAN"), ownership_type = c("INDIVIDUAL", "JOINT")) {
  stopifnot("account_id must be NULL or a character of length 1 (only able to filter on single ID)" = missing(account_id) || is.character(account_id) && length(account_id) == 1)

  if (!missing(account_type)) {
    account_type <- rlang::arg_match(account_type)
  }

  if (!missing(ownership_type)) {
    ownership_type <- rlang::arg_match(ownership_type)
  }

  req <- get_base_request() |>
    add_path_to_req("accounts")

  if (!missing(account_id)) {
    req <- add_path_to_req(req, account_id, "accounts_id")
  }

  if (!missing(account_type)) {
    req <- httr2::req_url_query(req, `filter[accountType]` = account_type)
  }

  if (!missing(ownership_type)) {
    req <- httr2::req_url_query(req, `filter[ownershipType]` = ownership_type)
  }

  query_up_api(req) |>
    process_response()
}
