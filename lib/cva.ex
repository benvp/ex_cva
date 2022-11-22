defmodule CVA do
  def cx(classes) when is_binary(classes), do: classes

  def cx(classes) when is_list(classes) do
    classes
    |> List.flatten()
    |> Enum.filter(&(!!&1 && &1 != ""))
    |> Enum.join(" ")
  end

  def cva(%{__cva__: cva_config} = assigns), do: cva("", cva_config, assigns)

  def cva(base, %{__cva__: cva_config} = assigns), do: cva(base, cva_config, assigns)

  def cva(config, props), do: cva("", config, props)

  def cva(base, config, props) when is_list(config) do
    cva(
      base,
      Enum.into(config, %{variants: nil, compound_variants: nil, default_variants: nil}),
      props
    )
  end

  def cva(base, %{variants: nil}, props), do: cx([base, props[:class]])

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
        props_with_default = Keyword.merge(config[:default_variants] || [], props)

        if compound == props_with_default do
          [class | acc]
        else
          acc
        end
      end)
    end
  end
end
