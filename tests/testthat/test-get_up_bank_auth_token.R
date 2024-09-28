test_that("get_up_bank_auth_token works", {
  expect_error(
    get_up_bank_auth_token()
  )

  withr::with_options(
    list(UP_TOKEN = "test_1"),
    expect_equal(
      get_up_bank_auth_token(),
      "test_1"
    )
  )

  withr::with_envvar(
    list(UP_TOKEN = "test_2"),
    expect_equal(
      get_up_bank_auth_token(),
      "test_2"
    )
  )

  withr::with_file(
    list(".env" = writeLines("UP_TOKEN=test_3", ".env")),
    expect_equal(
      get_up_bank_auth_token(),
      "test_3"
    )
  )
})
