defmodule CVA.Component do
  @moduledoc ~S'''
  Integrates CVA with Phoenix function components.

  The `variant/3` and `compound_variant/2` macros allow easy definition of variants and compound
  variants for a component. This also includes compile time checks for the specified variants.

  When using this module, please make sure that you add include :cva to your imports in
  `.formatter.exs`.

  ```elixir
  [
    import_deps: [:cva],
  ]
  ```

  ## Usage

      defmodule MyWeb.Components do
        use CVA.Component

        variant :intent, [
            primary: "bg-cyan-600",
            secondary: "bg-zinc-700",
            destructive: "bg-red-500"
          ],
          default: :secondary

        variant :size, [
            xs: "rounded px-2.5 py-1.5 text-xs",
            sm: "rounded-md px-3 py-2 text-sm",
            md: "rounded-md px-4 py-2 text-sm",
            lg: "rounded-md px-4 py-2 text-base",
            xl: "rounded-md px-6 py-3 text-base"
          ],
          default: :md

        compound_variant "uppercase", intent: :primary, size: :xl

        attr :rest, :global
        slot :inner_block

        def button(assigns) do
          ~H"""
          <button class={@cva_class} {@rest}><%= render_slot(@inner_block) %></button>
          """
        end
      end

      defmodule MyWeb.SomeLive do
        import MyWeb.Components

        def render(assigns) do
          ~H"""
          <.button intent="primary">Click me</.button>
          """
        end
      end
  '''

  import CVA
  import Phoenix.Component

  @doc ~S'''
  Declares a variant for HEEx function components.

  When declaring variants, an assign `cva_class` is added to the component. This assign contains
  the class according to all variant definitions of the component. This class is intended to
  be passed into the `class` attribute of the component.

  A component can have multiple variants.

  ## Arguments

    * `name` - an atom defining the name of the attribute. Note that attributes cannot define the
    same name as any other attributes or slots or attributes declared for the same component.

    * `variants` - a keyword list of variants.

    * `opts` - a keyword list of options. Defaults to `[]`.

  ## Options

      * `default` - the default variant.

      All other options will be passed to `Phoenix.Component.attr/3`.

  ## Example

      defmodule MyWeb.Components do
        use CVA.Component

        variant :intent, [
            primary: "bg-cyan-600",
            secondary: "bg-zinc-700",
            destructive: "bg-red-500"
          ],
          default: :secondary

        variant :size, [
            xs: "rounded px-2.5 py-1.5 text-xs",
            sm: "rounded-md px-3 py-2 text-sm",
            md: "rounded-md px-4 py-2 text-sm",
            lg: "rounded-md px-4 py-2 text-base",
            xl: "rounded-md px-6 py-3 text-base"
          ],
          default: :md

        def button(assigns) do
          ~H"""
          <button class={@cva_class} {@rest}><%= render_slot(@inner_block) %></button>
          """
        end
      end
  '''
  defmacro variant(name, variants, opts \\ [])
           when is_atom(name) and is_list(variants) and is_list(opts) do
    quote do
      if Module.get_attribute(__MODULE__, :__cva_variant_called__) do
        attr(:cva_class, :string, default: nil)
      end

      cva_variant = %{
        name: unquote(name),
        variants: unquote(variants),
        default: unquote(opts[:default]),
        line: __ENV__.line,
        file: __ENV__.file
      }

      Module.put_attribute(__MODULE__, :__cva_variants__, cva_variant)
      Module.put_attribute(__MODULE__, :__cva_variant_called__, true)

      attr(unquote_splicing(CVA.Component.__attr__!({name, variants}, opts)))
    end
  end

  @doc ~S'''
  Declares a compound variant for HEEx function components.

  A compound variant defines a set of required variants. If all variants are present, the
  given class will be assigned.

  A component can have multiple compound variants.

  ## Arguments

    * `class` - the class to add if all variants are present.

    * `variants` - a keyword list of required variants.

  ## Example

      defmodule MyWeb.Components do
        use CVA.Component

        variant :intent, [
            primary: "bg-cyan-600",
            secondary: "bg-zinc-700",
          ],
          default: :secondary

        variant :size, [
            md: "rounded-md px-4 py-2 text-sm",
            xl: "rounded-md px-6 py-3 text-base"
          ],
          default: :md

        compound_variant "uppercase", intent: :primary, size: :xl

        def button(assigns) do
          ~H"""
          <button class={@cva_class} {@rest}><%= render_slot(@inner_block) %></button>
          """
        end
      end
  '''
  defmacro compound_variant(class, variants) do
    quote do
      @__cva_compound_variants__ %{
        variants: unquote(variants),
        class: unquote(class)
      }
    end
  end

  defp pop_variants(env) do
    variants = Module.delete_attribute(env.module, :__cva_variants__) || []
    Enum.reverse(variants)
  end

  defp pop_compound_variants(env) do
    variants = Module.delete_attribute(env.module, :__cva_compound_variants__) || []
    Enum.reverse(variants)
  end

  def __attr__!({name, variants}, opts) do
    values =
      variants
      |> Keyword.keys()
      |> Enum.map(&Atom.to_string/1)

    cva_opts = [values: values]

    cva_opts =
      if opts[:default] != nil,
        do: Keyword.put(cva_opts, :default, Atom.to_string(opts[:default])),
        else: Keyword.put(cva_opts, :required, true)

    opts = Keyword.merge(opts, cva_opts)

    [name, :string, opts]
  end

  def __on_definition__(env, kind, name, _args, _guards, _body) do
    variant_defs = pop_variants(env)
    compound_variant_defs = pop_compound_variants(env)

    Module.put_attribute(env.module, :__cva_variant_called__, false)

    if not String.starts_with?(to_string(name), "__") and variant_defs != [] do
      default_variants =
        for %{name: name, default: default} <- variant_defs,
            not is_nil(default),
            do: {name, default}

      variants = for %{name: name, variants: v} <- variant_defs, do: {name, v}

      compound_variants =
        for %{variants: variants, class: class} <- compound_variant_defs,
            do: Keyword.put(variants, :class, class)

      configs =
        env.module
        |> Module.get_attribute(:__cva__)
        |> Map.put(name, %{
          kind: kind,
          config: [
            variants: variants,
            default_variants: default_variants,
            compound_variants: compound_variants
          ]
        })

      Module.put_attribute(env.module, :__cva__, configs)
    end

    :ok
  end

  defmacro __before_compile__(env) do
    configs = Module.get_attribute(env.module, :__cva__)

    names_and_defs =
      for {name, %{kind: kind, config: config}} <- configs do
        body =
          quote do
            assigns = Phoenix.Component.assign(assigns, :cva_class, cva(unquote(config), assigns))
            super(assigns)
          end

        full_def =
          quote do
            unquote(kind)(unquote(name)(assigns)) do
              unquote(body)
            end
          end

        {{name, 1}, full_def}
      end

    {names, defs} = Enum.unzip(names_and_defs)

    overridable =
      if names != [] do
        quote do
          defoverridable unquote(names)
        end
      end

    {:__block__, [], [overridable | defs]}
  end

  defmacro __using__(_opts \\ []) do
    quote do
      import CVA
      import unquote(__MODULE__)

      Module.put_attribute(__MODULE__, :before_compile, unquote(__MODULE__))
      Module.put_attribute(__MODULE__, :on_definition, unquote(__MODULE__))
      Module.put_attribute(__MODULE__, :__cva__, %{})
      Module.put_attribute(__MODULE__, :__cva_variant_called__, false)

      Module.register_attribute(__MODULE__, :__cva_variants__, accumulate: true)
      Module.register_attribute(__MODULE__, :__cva_compound_variants__, accumulate: true)
    end
  end
end
