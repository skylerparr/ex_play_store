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
      {:ok, %Tesla.Env{__client__: %Tesla.Client{adapter: {Tesla.Adapter.Hackney, :call, [[recv_timeout: 30000]]}, fun: nil, post: [], pre: []}, __module__: Tesla, body: "{\n  \"access_token\": \"ya29.c.ElpuBhL6zrCdxWvYbjNmgvKH9H-rsayPkXgoIOBi_5Tl5_7jPV76wTQ9UBwR3VHeVdWtHznK0VpYbVmdgfnnE07RJm6J104sUiKD3VuHTHeWBChnVGaj7ND6zvw\",\n  \"expires_in\": 3600,\n  \"token_type\": \"Bearer\"\n}", headers: [{"content-type", "application/json; charset=utf-8"}, {"vary", "X-Origin"}, {"vary", "Referer"}, {"date", "Mon, 10 Dec 2018 18:43:12 GMT"}, {"server", "ESF"}, {"cache-control", "private"}, {"x-xss-protection", "1; mode=block"}, {"x-frame-options", "SAMEORIGIN"}, {"x-content-type-options", "nosniff"}, {"alt-svc", "quic=\":443\"; ma=2592000; v=\"44,43,39,35\""}, {"accept-ranges", "none"}, {"vary", "Origin,Accept-Encoding"}, {"transfer-encoding", "chunked"}], method: :post, opts: [], query: [], status: 200, url: "https://www.googleapis.com/oauth2/v4/token"}}
		end)
    oauth = Auth.refresh_token
		
 		assert oauth.access_token == sample_access_token() |> Map.get("access_token")
 		assert oauth.token_type == sample_access_token() |> Map.get("token_type")
 		assert oauth.expires_in == sample_access_token() |> Map.get("expires_in")
		assert tesla_call |> was_called() == once()
  end

  defp sample_access_token do
    %{
			"access_token" => "ya29.c.ElpuBhL6zrCdxWvYbjNmgvKH9H-rsayPkXgoIOBi_5Tl5_7jPV76wTQ9UBwR3VHeVdWtHznK0VpYbVmdgfnnE07RJm6J104sUiKD3VuHTHeWBChnVGaj7ND6zvw",
			"token_type" => "Bearer",
			"expires_in" => 3600
		} 
  end
end


