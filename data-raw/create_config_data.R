# Script to set up config data


config_data <-
  list(
    accounts = list(
      var_names = c(
        "record_type", "account_id", "account_name", "account_type",
        "ownership_type", "balance_currency",
        "balance_value", "balance_value_base_units",
        "created_at", "link_to_transactions", "link_to_self"
      ),
      var_datetime = c("account_created_at"),
      var_with_timezone = "Australia/Sydney",
      var_numeric = c(
        "balance_value",
        "balance_value_base_units"
      ),
      var_to_drop = c("link_to_transactions", "link_to_self")
    ),
    transactions = list(
      var_names = c(
        "record_type", "transaction_id", "status", "raw_text", "description",
        "is_categorizable", "hold_info_amount_currency", "hold_info_amount_value",
        "hold_info_amount_value_base_units", "amount_currency", "amount_value", "amount_value_base_units",
        "car_purchase_method", "created_at", "performing_customer", "deep_link",
        "account_data_type", "account_id", "account_link", "category_data_type",
        "cetegory_data_id", "category_links_self", "category_links_related",
        "parent_category_data_type", "parent_category_data_id", "parent_category_link",
        "tag_link_self", "link_self", "settled_at", "transaction_type", "transfer_account_type",
        "transfer_account_id", "transfer_account_link", "message", "card_number_suffix"
      ),
      var_datetime = c("account_created_at"),
      var_with_timezone = "Australia/Sydney",
      var_numeric = c(
        "account_balance_value",
        "account_balance_value_base_units"
      ),
      var_to_drop = c("link_to_transactions", "link_to_self")
    )
  )

api_specs <-
  tibblify::parse_openapi_spec("data/up_bank_api_openapi.json") |> # From https://github.com/up-banking/api/blob/master/v1/openapi.json
  tibble::as_tibble()



  # type
  # id
  # attributes_status
  # attributes_rawText
  # attributes_description
  # attributes_isCategorizable
  # attributes_holdInfo_amount_currencyCode
  # attributes_holdInfo_amount_valu
  # attributes_holdInfo_amount_valueInBaseUnits
  # attributes_amount_currencyCode
  # attributes_amount_value
  # attributes_amount_valueInBaseUnits
  # attributes_cardPurchaseMethod_method
  # attributes_createdAt
  # attributes_performingCustomer_displayName
  # attributes_deepLinkURL
  # relationships_account_data_type
  # relationships_account_data_id
  # relationships_account_links_related
  # relationships_category_data_type
  # relationships_category_data_id
  # relationships_category_links_self
  # relationships_category_links_related
  # relationships_parentCategory_data_type
  # relationships_parentCategory_data_id
  # relationships_parentCategory_links_related
  # relationships_tags_links_self
  # links_self
  # attributes_cardPurchaseMethod_cardNumberSuffix
  # attributes_settledAt
  # attributes_transactionType
  # relationships_transferAccount_data_type
  # relationships_transferAccount_data_id
  # relationships_transferAccount_links_related
  # attributes_message


usethis::use_data(api_specs, internal = TRUE, overwrite = TRUE)
