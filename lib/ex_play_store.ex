defmodule ExPlayStore do
  use Application
  import Supervisor.Spec, warn: false
  alias ExPlayStore.OAuthToken
  
  @moduledoc """
  Documentation for ExPlayStore.
  """

  def start(_type, _args) do
    [ worker(OAuthToken, []) ]
    |> Supervisor.start_link(
      strategy: :one_for_all,
      name: ExPlayStore.Supervisor)
  end
end
