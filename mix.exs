defmodule BambooSmtp.Mixfile do
  use Mix.Project

  @project_url "https://github.com/fewlinesco/bamboo_smtp"

  def project do
    [
      app: :bamboo_smtp,
      version: "3.1.0",
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
      docs: [main: "readme", extras: ["README.md"]]
    ]
  end

  def application do
    [applications: [:gen_smtp, :logger, :bamboo]]
  end

  defp deps do
    [
      {:bamboo, "~> 1.6"},
      {:credo, "~> 1.4.1", only: [:dev, :test]},
      {:earmark, ">= 1.3.2", only: :docs},
      {:excoveralls, "~> 0.13.3", only: :test},
      {:ex_doc, ex_doc_version(), only: :docs},
      {:gen_smtp, "~> 1.0.1"},
      {:inch_ex, "~> 2.0.0", only: :docs}
    ]
  end

  defp ex_doc_version do
    if Version.match?(System.version(), "~> 1.7") do
      "~> 0.23.0"
    else
      "~> 0.18.4"
    end
  end

  defp package do
    [
      maintainers: ["Kevin Disneur", "Thomas Gautier"],
      licenses: ["MIT"],
      links: %{"GitHub" => @project_url}
    ]
  end
end
