defmodule CVA do
  def cx(classes) when is_binary(classes), do: classes

  def cx(classes) when is_list(classes) do
    classes
    |> List.flatten()
    |> Enum.filter(&(!!&1 && &1 != ""))
    |> Enum.join(" ")
  end

  def cva(config), do: cva("", config)

  def cva(base, config) when is_list(config) do
    cva(
      base,
      Enum.into(config, %{variants: nil, compound_variants: nil, default_variants: nil})
    )
  end

  def cva(base, %{variants: nil}) do
    fn props ->
      cx([base, props[:class]])
    end
  end

  def cva(base, config) do
    fn props ->
      cx([
        base,
        variant_class_names(config, props),
        compound_variant_class_names(config, props),
        props[:class]
      ])
    end
  end

  defp variant_class_names(_config, %{variants: nil}), do: []

  defp variant_class_names(config, props) do
    config[:variants]
    |> Map.keys()
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
        {class, compound} = Map.pop(compound_variant, :class)
        props_with_default = Map.merge(config[:default_variants] || %{}, props)

        if compound == props_with_default do
          [class | acc]
        else
          acc
        end
      end)
    end
  end
end
