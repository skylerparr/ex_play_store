defmodule ExPlayStore.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_play_store,
     version: "0.0.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      mod: {ExPlayStore, []},
      applications: [:poison, :tesla, :syringe, :ibrowse, :env_config],
      extra_applications: [:logger, :json_web_token]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:syringe, "~> 0.10.0"},
      {:poison, "~> 3.0.0", override: true},
      {:tesla, "~> 0.6.0"},
      {:ibrowse, "~> 4.2"},
      {:env_config, "~> 0.1.0"},
      {:json_web_token, github: "garyf/json_web_token_ex"}
    ]
  end
end
