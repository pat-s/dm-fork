context("test-filter-dm")

test_that("cdm_filter() works as intended for reversed dm", {
  map(
    .x = dm_for_filter_rev_src,
    ~ expect_identical(
      cdm_filter(.x, t1, a < 8, a > 3) %>% cdm_get_tables() %>% map(collect),
      rev(output_1)
    )
  )
})

test_that("cdm_filter() works as intended?", {
  map(
    .x = dm_for_filter_src,
    ~ expect_identical(
      cdm_filter(.x, t1, a < 8, a > 3) %>% cdm_get_tables() %>% map(collect),
      output_1
    )
  )
})

test_that("cdm_filter() works as intended for inbetween table", {
  map(
    .x = dm_for_filter_src,
    ~ expect_identical(
      cdm_filter(.x, t3, g == "five") %>% cdm_get_tables() %>% map(collect),
      output_3
    )
  )
})

test_that("cdm_filter() fails when intended in the right way?", {
  map(
    .x = dm_for_filter_src,
    ~ expect_error(
      cdm_rm_pk(.x, t3, rm_referencing_fks = TRUE) %>%
        cdm_filter(t3, g == "five"),
      class = cdm_error("no_pk_filter"),
      error_txt_pk_filter_missing("t3")
    )
  )
})

test_that("cdm_filter() returns original `dm` object when ellipsis empty", {
  map(
    dm_for_filter_src,
    ~ expect_equal(
      cdm_filter(.x, t3),
      .x
    )
  )
})

test_that("cdm_filter() fails when no table name is provided", {
  map(
    dm_for_filter_src,
    ~ expect_error(
      cdm_filter(.x),
      class = cdm_error("table_not_in_dm"),
      error_txt_table_not_in_dm("")
    )
  )
})