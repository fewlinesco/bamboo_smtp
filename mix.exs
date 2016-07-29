defmodule BambooSmtp.Mixfile do
  use Mix.Project

  @project_url "https://github.com/fewlinesco/bamboo_smtp"

  def project do
    [app: :bamboo_smtp,
     version: "1.1.0",
     elixir: "~> 1.2",
     source_url: @project_url,
     homepage_url: @project_url,
     name: "Bamboo SMTP Adapter",
     description: "A Bamboo adapter for SMTP",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     package: package,
     deps: deps,
     docs: [main: "README", extras: ["README.md"]]]
  end

  def application do
    [applications: [:gen_smtp, :logger, :bamboo]]
  end

  defp deps do
    [
      {:bamboo, "~> 0.6.0"},
      {:gen_smtp, "~> 0.11.0"},
      {:ex_doc, "~> 0.13.0", only: :dev},
      {:earmark, ">= 1.0.1", only: :dev},
      {:dogma, "~> 0.1", only: [:dev, :test]},
      {:excoveralls, "~> 0.4", only: :test},
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
