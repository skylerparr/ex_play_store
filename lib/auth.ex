defmodule ExPlayStore.Auth do
  use Injector

  alias ExPlayStore.AccessToken
  alias ExPlayStore.Util
  alias ExPlayStore.TeslaClient

  inject ExPlayStore.Settings
  inject JsonWebToken.Algorithm.RsaUtil
  inject Tesla

	import Util, only: [seconds_since_epoch: 0, one_hour_from_now: 0]

  @audience "https://www.googleapis.com/oauth2/v4/token"
  @grant_type "urn:ietf:params:oauth:grant-type:jwt-bearer"

  def refresh_token do

    params = %{
      grant_type: @grant_type,
      assertion: jwt()
    }
    |> Enum.into([], fn({key, val}) ->
      "#{key}=#{val}"
    end)
    |> Enum.join("&")

    %{"access_token" => access_token,
      "token_type" => token_type,
      "expires_in" => expires_in} = Tesla.post(TeslaClient.client(), @audience, params, headers: ["Content-Type": "application/x-www-form-urlencoded"])
    |> elem(1)
    |> Map.get(:body)
    |> Poison.decode!

    %AccessToken{
      access_token: access_token,
      token_type: token_type,
      expires_in: expires_in,
      expires_at: seconds_since_epoch() + expires_in
    }
  end

  def jwt do
    JsonWebToken.sign(claim_set(), %{alg: "RS256", key: private_key()})
  end

  defp private_key do
    Settings.private_key
    |> RsaUtil.private_key
  end

  def claim_set do
    %{
      iss:   Settings.client_email,
      scope: Settings.scopes,
      aud:   @audience,
      iat:   seconds_since_epoch(),
      exp:   one_hour_from_now()
    }
  end
end

