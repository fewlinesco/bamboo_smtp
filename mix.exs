defmodule BambooSmtp.Mixfile do
  use Mix.Project

  @project_url "https://github.com/fewlinesco/bamboo_smtp"

  def project do
    [
      app: :bamboo_smtp,
      version: "1.6.0",
      elixir: "~> 1.4 or 1.7",
      source_url: @project_url,
      homepage_url: @project_url,
      name: "Bamboo SMTP Adapter",
      description: "A Bamboo adapter for SMTP",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      package: package(),
      deps: deps(),
      docs: [main: "readme", extras: ["README.md"]]
    ]
  end

  def application do
    [applications: [:gen_smtp, :logger, :bamboo]]
  end

  defp deps do
    [
      {:bamboo, "~> 1.2"},
      {:credo, "~> 1.0.5", only: [:dev, :test]},
      {:earmark, ">= 1.3.2", only: :docs},
      {:ex_doc, "~> 0.20.2 or 0.18.4", only: :docs},
      {:excoveralls, "~> 0.11.1", only: :test},
      {:gen_smtp, "~> 0.14.0"},
      {:inch_ex, "~> 2.0.0", only: :docs}
    ]
  end

  defp package do
    [
      maintainers: ["Kevin Disneur", "Thomas Gautier"],
      licenses: ["MIT"],
      links: %{"GitHub" => @project_url}
    ]
  end
end
