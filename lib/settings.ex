defmodule ExPlayStore.Settings do
  use Injector

  inject EnvConfig
  inject File

  def private_key do
    EnvConfig.get(:ex_play_store, :private_key) ||
    EnvConfig.get(:ex_play_store, :private_key_path) |> read_file ||
    private_key_json() |> Map.get("private_key")
  end

  defp read_file(nil), do: nil
  defp read_file(path) do
    with {:ok, data} <- File.read(path) do
      data
    else
      nil
    end
  end

  defp private_key_json do
    EnvConfig.get(:ex_play_store, :private_key_json)
    |> read_file
    |> Poison.decode!
  end

  def client_email do
    EnvConfig.get(:ex_play_store, :client_email) ||
    private_key_json() |> Map.get("client_email")
  end

  def scopes do
    EnvConfig.get(:ex_play_store, :scopes)
    |> parse_scopes
  end

  defp parse_scopes(items) when is_binary(items), do: items 
  defp parse_scopes(items) when is_list(items), do: Enum.join(items, " ")

end
