defmodule ExPlayStore.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_play_store,
     version: "0.1.0",
     elixir: "~> 1.4",
     description: description(),
     package: package(),
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
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:syringe, "~> 1.1.0"},
      {:poison, "~> 3.1.0"},
      {:tesla, "~> 0.10.0"},
      {:ibrowse, "~> 4.2"},
      {:env_config, "~> 0.1.0"},
      {:json_web_token, github: "garyf/json_web_token_ex"}
    ]
  end

  defp description do
    """
    Application to work with google play receipt verification. 
    Should be extendable to other google play services.
    """
  end

  defp package do
    [
      name: :ex_play_store,
      files: ["lib", "mix.exs", "README*", "config"],
      maintainers: ["Skyler Parr"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/skylerparr/ex_play_store"}
    ]
  end
end
