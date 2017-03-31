defmodule ExPlayStore.OAuthToken do
  use GenServer
  use Injector
  import ExPlayStore.Util

  inject ExPlayStore.Auth

  def start_link(opts \\ nil) do
    GenServer.start_link(__MODULE__, nil, opts || [name: __MODULE__])
  end

  def get(pid \\ nil) do
    GenServer.call(pid || __MODULE__, :get)
    |> store_and_return(pid || __MODULE__)
  end

  def store_and_return(nil, pid) do 
    token = Auth.refresh_token
    GenServer.call(pid || __MODULE__, {:set, token})
  end

  def store_and_return(token, pid) do
    if(token.expires_at < seconds_since_epoch()) do
      store_and_return(nil, pid)
    else
      %{token | expires_in: token.expires_at - seconds_since_epoch()}
    end
  end

  def handle_call(:get, _from, token) do
    {:reply, token, token}
  end

  def handle_call({:set, token}, _from, _old_token) do
    {:reply, token, token}
  end

end

