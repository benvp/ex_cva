# Class Variance Authority for Elixir

This is a port of the awesome [`cva`](https://github.com/joe-bell/cva) JavaScript library.

There hasn't been any initial release yet. It's a work in progress.

## Example

This is an example using CVA with a Phoenix function component.

```elixir
defmodule MyAppWeb.SettingsLive do
  use MyAppWeb, :live_view

  import CVA.LiveView

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-8 pt-12 px-12">
      <div class="flex space-x-4">
        <.button intent="primary" size="xs">Click me</.button>
        <.button intent="primary" size="sm">Click me</.button>
        <.button intent="secondary" size="md">Click me</.button>
        <.button intent="secondary" size="lg">Click me</.button>
        <.button intent="secondary" size="xl">Click me</.button>
      </div>
    </div>
    """
  end


  attr_cva(
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
      intent: :primary
    ]
  )

  attr :rest, :global, default: %{}
  slot :inner_block

  def button(assigns) do
    assigns = assign_cva(assigns)

    ~H"""
    <button class={@class} {@rest}><%= render_slot(@inner_block) %></button>
    """
  end
end
```

## Acknowledgements

- [**cva**](https://github.com/joe-bell/cva) ([Joe Bell](https://github.com/joe-bell))
  Thank you for providing the JavaScript implementation. It inspired me to port this over to Elixir.
