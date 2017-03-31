defmodule ExPlayStoreOAuthTokenTest do
  use ExUnit.Case, async: true
  import Mocker

  alias ExPlayStore.{Auth, OAuthToken, AccessToken, Util}

  describe "get" do
    setup do
      mock(Auth)
      intercept(Auth, :refresh_token, [], with: fn() ->
        get_token()
      end)
      {:ok, pid} = OAuthToken.start_link([])
      {:ok, pid: pid}
    end

    test "should refresh access token cache is empty", %{pid: pid} do
      token = OAuthToken.get(pid)
      assert token == get_token()
      assert was_called(Auth, :refresh_token, []) == once()
    end

    test "should store refresh token for later reference", %{pid: pid} do
      token = OAuthToken.get(pid)
      assert GenServer.call(pid, :get) == token
    end

    test "should fetch token from cache if present", %{pid: pid} do
      token = OAuthToken.get(pid)
      assert OAuthToken.get(pid) == token
      assert OAuthToken.get(pid) == token
      assert OAuthToken.get(pid) == token

      assert was_called(Auth, :refresh_token, []) == once()
    end
  end

  describe "refresh expired" do
    setup do
      mock(Auth)
      {:ok, pid} = OAuthToken.start_link([])
      {:ok, pid: pid}
    end

    test "should refresh token if expired", %{pid: pid} do
      intercept(Auth, :refresh_token, [], with: fn() ->
        get_token()
      end)

      new_token = %AccessToken{
        access_token: "token",
        expires_in: Util.seconds_since_epoch - 9600,
        token_type: "type"
      }
      
      OAuthToken.get(pid)
      GenServer.call(pid, {:set, new_token})
      token = OAuthToken.get(pid)
      assert token == get_token()
      assert was_called(Auth, :refresh_token, []) == twice()
    end
  end

  defp get_token do
    %AccessToken{
      access_token: "token",
      expires_in: Util.one_hour_from_now,
      token_type: "type"
    }
  end
end
