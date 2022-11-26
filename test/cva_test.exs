defmodule CVATest do
  use ExUnit.Case

  import CVA

  describe "cx" do
    test "correctly merges classes 1" do
      class = cx([nil, ""])
      assert class == ""
    end

    test "correctly merges classes 2" do
      class = cx([["foo", nil, "bar", "baz"]])
      assert class == "foo bar baz"
    end

    test "correctly merges classes 3" do
      class = cx(["foo", nil, "bar", "baz"])
      assert class == "foo bar baz"
    end

    test "correctly merges classes 4" do
      class =
        cx([
          "foo",
          [
            nil,
            ["bar"],
            [
              [
                "baz",
                "qux",
                "quux",
                "quuz",
                [[[[[[[[["corge", "grault"]]]]], "garply"]]]]
              ]
            ]
          ]
        ])

      assert class == "foo bar baz qux quux quuz corge grault garply"
    end
  end
end
