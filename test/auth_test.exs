defmodule ExPlayStore.AuthTest do
  use ExUnit.Case, async: true
  import Mocker
  alias ExPlayStore.{Auth, Settings}

  setup do
    mock(Settings)
    mock(Tesla)

    intercept(Settings, :private_key, [], with: fn() -> 
      File.read!("test/id_rsa")
    end)

    intercept(Settings, :client_email, [], with: fn() ->
      "client@email.com"
    end)

    intercept(Settings, :scopes, [], with: fn() ->
      "scopes"
    end)

    :ok
  end

  test "should fetch access token" do
		tesla_call = intercept(Tesla, :post, [
      any(),
			"https://www.googleapis.com/oauth2/v4/token",
      any(),
      [headers: ["Content-Type": "application/x-www-form-urlencoded"]]
		], with: fn(_,_,_, _) ->
      %{body: sample_access_token() |> Poison.encode!}
		end)
    oauth = Auth.refresh_token
		
 		assert oauth.access_token == sample_access_token() |> Map.get("access_token")
 		assert oauth.token_type == sample_access_token() |> Map.get("token_type")
 		assert oauth.expires_in == sample_access_token() |> Map.get("expires_in")
		assert tesla_call |> was_called() == once()
  end

  defp sample_access_token do
		%{
			"access_token" => "1/8xbJqaOZXSUZbHLl5EOtu1pxz3fmmetKx9W8CV4t79M",
			"token_type" => "Bearer",
			"expires_in" => 3600
		} 
  end
end


