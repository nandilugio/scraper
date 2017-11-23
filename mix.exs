defmodule ContentAnalysis.Mixfile do
  use Mix.Project

  def project do
    [
      app: :content_analysis,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      escript: [main_module: ContentAnalysis.App],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpotion]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.18.0"},
      {:httpotion, "~> 3.0.2"}
    ]
  end
end
