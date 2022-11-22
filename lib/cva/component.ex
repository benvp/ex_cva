defmodule CVA.Component do
  import CVA
  import Phoenix.Component

  def assign_cva(assigns, name \\ :class) do
    assign(assigns, name, cva(assigns))
  end

  defmacro attr_cva(config) do
    ast =
      Enum.map(config[:variants], fn v ->
        quote do
          attr(unquote_splicing(__attr__!(v, config[:default_variants])))
        end
      end)

    cva_ast =
      quote do
        attr(:__cva__, :list, default: unquote(config))
      end

    ast ++ [cva_ast]
  end

  def __attr__!({name, value}, default_variants) do
    values =
      value
      |> Keyword.keys()
      |> Enum.map(&Atom.to_string/1)

    opts = [values: values]

    opts =
      if Keyword.has_key?(default_variants, name),
        do: Keyword.put(opts, :default, Atom.to_string(default_variants[name])),
        else: Keyword.put(opts, :required, true)

    [name, :string, opts]
  end

  defmacro __using__(_opts \\ []) do
    quote do
      import CVA
      import unquote(__MODULE__)
      require unquote(__MODULE__)
    end
  end
end
