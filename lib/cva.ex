defmodule CVA do
  @moduledoc """
  Construct classes with variant definitions.

  A variant consists of a name and a class. These variants are defined by providing a declarative
  set of nested keyword lists.

      defmodule MyCVA do
        import CVA

        def button(props) do
          config = [
            variants: [
              intent: [
                primary: "bg-cyan-600",
                secondary: "bg-zinc-700",
                destructive: "bg-red-500"
              ],
              size: [
                xs: "rounded px-2.5 py-1.5 text-xs",
                sm: "rounded-md px-3 py-2 text-sm",
                md: "rounded-md px-4 py-2 text-sm",
                lg: "rounded-md px-4 py-2 text-base",
                xl: "rounded-md px-6 py-3 text-base"
              ]
            ]
          ]

          cva(config, props)
        end
      end

    Invoking `button/1` with the desired variants will return a class name including
    the classes specified in the config.

        button(intent: :primary, size: :md) # -> "bg-cyan-600 rounded-md px-4 py-2 text-sm"

    See `cva/3` for more info.


    ## Usage with Phoenix function components.

    CVA integrates nicely with Phoenix function components by providing `variant/3` and
    `compound_variant/2` macros.

    Please refer to the `CVA.Component` module.
  """

  @doc """
  Merges a list of classes into a single class string removing any nil or empty strings.
  Class lists can be infinitely nested.
  """
  def cx(classes) when is_binary(classes), do: classes

  def cx(classes) when is_list(classes) do
    classes
    |> List.flatten()
    |> Enum.filter(&(!!&1 && &1 != ""))
    |> Enum.join(" ")
  end

  @doc """
  See `cva/3`.
  """
  def cva(config) when is_list(config), do: cva("", config, [])

  @doc """
  See `cva/3`.
  """
  def cva(config, props), do: cva("", config, props)

  def cva(base, config, props) when is_list(config) do
    cva(
      base,
      Enum.into(config, %{variants: nil, compound_variants: nil, default_variants: nil}),
      Enum.into(props, %{})
    )
  end

  def cva(base, %{variants: nil}, props), do: cx([base, props[:class]])

  @doc """
  Construct a class string from a variant configuration.

  Accepts a base class string, a variant configuration, and a list of props.

      config = [
        variants: [
          intent: [
            primary: "bg-cyan-600",
            secondary: "bg-zinc-700",
            destructive: "bg-red-500"
          ],
          size: [
            xs: "rounded px-2.5 py-1.5 text-xs",
            sm: "rounded-md px-3 py-2 text-sm",
            md: "rounded-md px-4 py-2 text-sm",
            lg: "rounded-md px-4 py-2 text-base",
            xl: "rounded-md px-6 py-3 text-base"
          ]
        ],
        default_variants: [
          intent: :secondary,
          size: :md
        ],
        compound_variants: [
          [intent: :primary, size: :xl, class: "uppercase"]
        ]
      ]

      cva("base", config, intent: :primary, size: :md) # -> "base bg-cyan-600 rounded-md px-4 py-2 text-sm"
      cva("base", config, intent: :primary, size: :xl) # -> "base bg-cyan-600 rounded-md px-6 py-3 text-base uppercase"
      cva("base", config, intent: :primary, size: :xl) # -> "base bg-cyan-600 rounded-md px-6 py-3 text-base uppercase"

      cva("base", config) # -> "base bg-zinc-700 rounded-md px-4 py-2 text-sm"
      cva("base", config, intent: :primary) # -> "base bg-cyan-600 rounded-md px-4 py-2 text-sm"

  ## Config

  The configuration is a keyword list with the following keys:

    * `:variants` - A keyword list of variants. Each variant is a keyword list of
      variant names and classes.
    * `:compound_variants` - A list of compound variants. Each compound
      variant is a keyword list of required variants and a `:class` key to specify the class
      which should be applied if all variants are present.
    * `:default_variants` - A keyword list of default variants. For example `[intent: :primary]`.

  ## Props

  Props define the variants to be applied. Each key in the props list must be a variant name.
  Values can either be an atom or a string.

  ### Special props

    * `:class` - A class string or list of classes. This class is applied last.
  """
  def cva(base, config, props) do
    cx([
      base,
      variant_class_names(config, props),
      compound_variant_class_names(config, props),
      props[:class]
    ])
  end

  defp variant_class_names(_config, %{variants: nil}), do: []

  defp variant_class_names(config, props) do
    config[:variants]
    |> Keyword.keys()
    |> Enum.map(fn variant ->
      if Map.has_key?(props, variant) && props[variant] == nil do
        nil
      else
        variant_prop = props[variant]
        default_variant_prop = config[:default_variants][variant]

        variant_key =
          case variant_prop do
            p when is_binary(p) -> String.to_existing_atom(p)
            p -> p
          end || default_variant_prop

        config[:variants][variant][variant_key]
      end
    end)
  end

  defp compound_variant_class_names(config, props) do
    compound_variants = config[:compound_variants]

    if compound_variants do
      compound_variants
      |> Enum.reduce([], fn compound_variant, acc ->
        {class, compound} = Keyword.pop(compound_variant, :class)
        props_with_default = Keyword.merge(config[:default_variants] || [], Map.to_list(props))

        match? =
          Enum.all?(compound, fn {k, v} ->
            p =
              if is_binary(props_with_default[k]),
                do: String.to_existing_atom(props_with_default[k]),
                else: props_with_default[k]

            p == v
          end)

        if match? do
          [class | acc]
        else
          acc
        end
      end)
    end
  end
end
