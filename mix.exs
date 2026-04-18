defmodule SitemapBuilder.MixProject do
  use Mix.Project

  @version "0.1.2"
  @source_url "https://github.com/exfoundry/sitemap_builder"

  def project do
    [
      app: :sitemap_builder,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "SitemapBuilder",
      source_url: @source_url,
      docs: [
        main: "SitemapBuilder",
        source_ref: "v#{@version}",
        extras: ["CHANGELOG.md"],
        skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Minimal, pipeline-friendly XML sitemap generator."
  end

  defp package do
    [
      maintainers: ["Sascha Brink"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "https://hexdocs.pm/sitemap_builder/changelog.html"
      },
      files: ~w(lib mix.exs README.md CHANGELOG.md LICENSE usage-rules.md)
    ]
  end
end
