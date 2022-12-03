locals_without_parens = [
  variant: 3,
  variant: 2,
  compound_variant: 2
]

# Used by "mix format"
[
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
