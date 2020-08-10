defmodule ReverseIap.MixProject do
  use Mix.Project

  def project do
    [
      app: :reverse_iap,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ReverseIap.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:reverse_proxy_plug, "~> 1.3.0"},
      {:google_api_iam_credentials, "~> 0.11"},
      {:goth, "~> 1.2.0"},
    ]
  end
end
