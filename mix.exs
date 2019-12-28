defmodule StructCop.MixProject do
  use Mix.Project

  def project do
    [
      app: :struct_cop,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      test_paths: ["lib"],
      test_pattern: "*.test.exs",
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps(),
      name: "StructCop",
      description: description(),
      source_url: "https://github.com/HarenBroog/struct_cop",
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ecto, "~> 3.1"},
      {:excoveralls, "~> 0.11.1", only: :test},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.9.0", only: [:test, :dev]}
    ]
  end

  defp description do
    "StructCop is a library that was aimed to introduce data correctness and type corecion into Elixir structs. It also simplifies building valid structs with smart constructors."
  end

  defp docs do
    [
      main: "readme",
      canonical: "http://hexdocs.pm/struct_cop",
      extra_section: "Pages",
      extras: [
        "README.md",
        "docs/examples/use_cases.md"
      ],
      groups_for_extras: [
        Examples: ~r/docs\/examples\/.?/
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Damian Romanów"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/HarenBroog/struct_cop"}
    ]
  end
end
