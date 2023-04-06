# Changelog

All notable changes to this project will be documented in this file.

## [v0.2.0] (2022-04-06)

## Improvements

* Add `.formatter.exs` to files to allow `import_deps: [:cva]`.

## [v0.2.0] (2022-12-06)

### Improvements

* `variant/2` now properly supports boolean values. You can now do something like the following:

```elixir
variant :disabled,
        [true: "disabled-class", false: "enabled-class"],
        default: false

# or

variant :disabled,
        [true: "disabled-class"],
        default: nil

def button(assigns) do
  ~H"""
  <button class={@cva_class} disabled={@disabled}>
    <%= render_slot(@inner_block) %>
  </button>
  """
end

# ... where you use that component

<.button disabled>Click me</.button>

# -> <button class="disabled-class" disabled>Click me</button>
```

### Changes

* `variant/2` does not automatically infer the `required` option anymore. If you want to make a variant mandatory, you have to provide the `required: true` option.

* `variant/2` now allows `nil` as a valid value.

### Bugfixes

* Fixes an issue where defining 3 variants would cause an `attr` already defined error.


## [v0.1.2] (2022-12-03)

### Bugfixes

* Add `variant: 2` to formatter.
* Fixes an issue where a `class` assign would accidentally be merged into `@cva_class` without
  explicitly declaring it.

## [v0.1.1] (2022-11-26)

### Bugfixes

* Fix formatter exports

## [v0.1.0] (2022-11-26)

🚀 Initial release
