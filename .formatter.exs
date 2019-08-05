# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{lib,test}/**/*.{ex,exs}"],
  import_deps: [:ecto],
  locals_without_parens: [
    assert_raise: 1
  ]
]
