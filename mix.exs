defmodule OrdSet.MixProject do
  use Mix.Project

  def project do
    [
      app: :ord_set,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        # The main page in the docs
        main: "OrdSet",
        markdown_processor: {ExDoc.Markdown.Earmark, footnotes: true}
      ],
      description: "Elixir wrapper around :ordsets",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/thomas9911/ordset"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
