defmodule BambooSmtp.Mixfile do
  use Mix.Project

  @project_url "https://github.com/fewlinesco/bamboo_smtp"
  @version "4.2.2"

  def project do
    [
      app: :bamboo_smtp,
      version: @version,
      elixir: "~> 1.7",
      source_url: @project_url,
      homepage_url: @project_url,
      name: "Bamboo SMTP Adapter",
      description: "A Bamboo adapter for SMTP",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [applications: [:gen_smtp, :logger, :bamboo]]
  end

  defp deps do
    [
      # core
      {:bamboo, "~> 2.2.0"},
      {:gen_smtp, "~> 1.2.0"},

      # dev / test
      {:credo, "~> 1.6.1", only: [:dev, :test]},
      {:excoveralls, "~> 0.14.0", only: :test},

      # doc
      {:ex_doc, "~> 0.28.4", only: :docs},
      {:inch_ex, "~> 2.0.0", only: :docs}
    ]
  end

  defp package do
    [
      maintainers: ["Kevin Disneur", "Thomas Gautier"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "#{@project_url}/blob/main/CHANGELOG.md",
        "GitHub" => @project_url
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md": [title: "Changelog"]]
    ]
  end
end
