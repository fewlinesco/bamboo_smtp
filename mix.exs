defmodule BambooSmtp.Mixfile do
  use Mix.Project

  @project_url "https://github.com/fewlinesco/bamboo_smtp"

  def project do
    [app: :bamboo_smtp,
     version: "1.2.1",
     elixir: "~> 1.2",
     source_url: @project_url,
     homepage_url: @project_url,
     name: "Bamboo SMTP Adapter",
     description: "A Bamboo adapter for SMTP",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     package: package(),
     deps: deps(),
     docs: [main: "README", extras: ["README.md"]]]
  end

  def application do
    [applications: [:gen_smtp, :logger, :bamboo]]
  end

  defp deps do
    [
      {:bamboo, "~> 0.7.0"},
      {:dogma, "~> 0.1", only: [:dev, :test]},
      {:earmark, ">= 1.0.1", only: :dev},
      {:ex_doc, "~> 0.13.0", only: :dev},
      {:excoveralls, "~> 0.4", only: :test},
      {:gen_smtp, "~> 0.11.0"},
      {:inch_ex, "~> 0.5.3", only: :docs}
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
