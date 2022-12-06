defmodule CVA.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :cva,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      name: "CVA",
      homepage_url: "https://github.com/benvp/ex_cva",
      description: """
      Class Variance Authority.
      Easily construct classes with variant definitions.
      """
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_live_view, "~> 0.18"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "CVA",
      source_ref: "v#{@version}",
      source_url: "https://github.com/benvp/ex_cva"
    ]
  end

  defp package do
    [
      maintainers: ["Benjamin von Polheim"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://hexdocs.pm/cva/changelog.html",
        GitHub: "https://github.com/benvp/ex_cva"
      },
      files:
        ~w(lib) ++
          ~w(CHANGELOG.md LICENSE.md mix.exs README.md)
    ]
  end
end
