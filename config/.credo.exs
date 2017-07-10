%{
  configs: [
    %{
      name: "default",
      strict: true,
      files: %{
        included: ["lib/"],
        excluded: []
      },
      checks: [
        {Credo.Check.Design.AliasUsage, false},
        # We can't keep it because it would force us to reformat version numbers (i.e: 20161023)
        # and to reformat our invoice amounts (i.e: 145_23)
        {Credo.Check.Readability.LargeNumbers, false},
        {Credo.Check.Readability.MaxLineLength, max_length: 120},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Warning.IoInspect, false}
      ]
    }
  ]
}
