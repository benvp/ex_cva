![CVA](/.github/assets/meta.png)

<h1 align="center">
cva for elixir
<span align="center" style="display: block; font-size: 14px; margin: 8px 0">Easily construct classes with variant definitions.</span>
</h1>

<p align="center">Class Variance Authority for Elixir</p>

<p align="center">
  <a href="https://hexdocs.pm/cva">
    <img alt="Documentation" src="https://img.shields.io/badge/documentation-gray" />
  </a>
  <a href="https://hex.pm/packages/cva">
    <img alt="hex" src="https://img.shields.io/hexpm/v/cva.svg" />
  </a>
  <a href="https://twitter.com/benvp_">
    <img alt="Follow @benvp_ on Twitter" src="https://img.shields.io/twitter/follow/benvp_.svg?style=social&label=Follow" />
  </a>
</p>


## Introduction

Building out core HEEx function components like `button`, `heading`, `link` in general requires
some way to distinguish between different appearances of the component. This is generally achieved
by concatenating class strings or by extracting them into separate functions. In addition, maintaining proper definitions of supported `attr` `:value` options is required.

`ex_cva` aims to make this process convenient by providing a clean and maintainable way to define component variants.

## Usage with HEEx function components

Configure a few variants with defaults and optionally add compound variants. CVA will take care of creating the proper class names.

One more goodie: it even creates compile-time checks for your variants to make sure all required
variants are applied and contain correct values (thanks to `Phoenix.Component.attr/3`).

```elixir
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
```

## Raw `cva` usage

Even though `ex_cva` shines when working with function components, you can still use the raw `cva` function to generate classes.

```elixir
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

button(intent: :primary, size: :md) # -> "bg-cyan-600 rounded-md px-4 py-2 text-sm"
```

## Acknowledgements

- [**cva**](https://github.com/joe-bell/cva) ([Joe Bell](https://github.com/joe-bell))
  Thank you for providing the JavaScript implementation. It inspired me to port this over to Elixir. I hope you don't mind that I hijacked your logo. If you are not feeling well about that, feel free to shoot me a message.

## Contributing

Contributions are very welcome. To get it up on your local machine, just check out the repo and run

```bash
mix deps.get
mix test
```
