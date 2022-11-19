defmodule CVA.LiveView do
  import CVA
  import Phoenix.Component

  def assign_cva(assigns, base, config) do
    make_class = cva(base, config)
    assign(assigns, :class, make_class.(assigns))
  end
end
