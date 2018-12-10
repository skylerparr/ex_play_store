defmodule ExPlayStore.PurchaseVerificationTest do
  use ExUnit.Case, async: true
  import Mocker
  alias ExPlayStore.{Util, OAuthToken, PurchaseReceipt, PurchaseVerification, AccessToken, ErrorPurchaseReceipt}

  setup do
    mock(Tesla)
    mock(OAuthToken)
    :ok
  end

  test "should return google receipt data" do
    intercept(OAuthToken, :get, [], with: fn() ->
      %AccessToken{
        access_token: "34lksjva30d",
        expires_in: Util.one_hour_from_now,
        token_type: "Bearer"
      }
    end)
    headers = ["Authorization": "Bearer 34lksjva30d"]

    sample_receipt = sample_receipt()
    consumed = consumed_receipt()

    intercept(Tesla, :get, ["https://www.googleapis.com/androidpublisher/v2/applications/com.example/purchases/products/fire.sale/tokens/09vuisohj", [headers: headers]], with: fn(_,_) ->
      body = sample_receipt |> Poison.encode!
      {:ok, %Tesla.Env{__client__: %Tesla.Client{adapter: {Tesla.Adapter.Hackney, :call, [[recv_timeout: 30000]]}, fun: nil, post: [], pre: []}, __module__: Tesla, body: "#{body}", headers: [{"content-type", "application/json; charset=utf-8"}, {"vary", "X-Origin"}, {"vary", "Referer"}, {"date", "Mon, 10 Dec 2018 18:43:12 GMT"}, {"server", "ESF"}, {"cache-control", "private"}, {"x-xss-protection", "1; mode=block"}, {"x-frame-options", "SAMEORIGIN"}, {"x-content-type-options", "nosniff"}, {"alt-svc", "quic=\":443\"; ma=2592000; v=\"44,43,39,35\""}, {"accept-ranges", "none"}, {"vary", "Origin,Accept-Encoding"}, {"transfer-encoding", "chunked"}], method: :post, opts: [], query: [], status: 200, url: "https://www.googleapis.com/oauth2/v4/token"}}
    end)
    receipt = PurchaseVerification.fetch_receipt("com.example", "fire.sale", "09vuisohj")
    assert receipt == consumed
  end

  test "should handle error verification struct" do
    intercept(OAuthToken, :get, [], with: fn() ->
      %AccessToken{
        access_token: "34lksjva30d",
        expires_in: Util.one_hour_from_now,
        token_type: "Bearer"
      }
    end)
    headers = ["Authorization": "Bearer 34lksjva30d"]

    sample_receipt = sample_failure()
    intercept(Tesla, :get, ["https://www.googleapis.com/androidpublisher/v2/applications/com.example/purchases/products/fire.sale/tokens/09vuisohj", [headers: headers]], with: fn(_,_) ->
      body = sample_receipt |> Poison.encode!
      {:ok, %Tesla.Env{__client__: %Tesla.Client{adapter: {Tesla.Adapter.Hackney, :call, [[recv_timeout: 30000]]}, fun: nil, post: [], pre: []}, __module__: Tesla, body: "#{body}", headers: [{"content-type", "application/json; charset=utf-8"}, {"vary", "X-Origin"}, {"vary", "Referer"}, {"date", "Mon, 10 Dec 2018 18:43:12 GMT"}, {"server", "ESF"}, {"cache-control", "private"}, {"x-xss-protection", "1; mode=block"}, {"x-frame-options", "SAMEORIGIN"}, {"x-content-type-options", "nosniff"}, {"alt-svc", "quic=\":443\"; ma=2592000; v=\"44,43,39,35\""}, {"accept-ranges", "none"}, {"vary", "Origin,Accept-Encoding"}, {"transfer-encoding", "chunked"}], method: :post, opts: [], query: [], status: 200, url: "https://www.googleapis.com/oauth2/v4/token"}}
    end)

    receipt = PurchaseVerification.fetch_receipt("com.example", "fire.sale", "09vuisohj")
    assert receipt == %ErrorPurchaseReceipt{
             domain: "global",
             message: "Invalid Value",
             reason: "invalid",
           }
  end

  defp sample_receipt do
    %{
      "consumptionState" => 1,
      "developerPayload" => "cray payload",
      "kind" => "3rd kind",
      "purchaseState" => 1,
      "purchaseTimeMillis" => Util.seconds_since_epoch * 1000
    }
  end

  defp sample_failure do
    %{"error" => %{"code" => 400, "errors" => [%{"domain" => "global", "message" => "Invalid Value", "reason" => "invalid"}], "message" => "Invalid Value"}}
  end

  defp consumed_receipt do
    %PurchaseReceipt{
      consumption_state: 1,
      developer_payload: "cray payload",
      kind: "3rd kind",
      purchase_state: 1,
      purchase_time_millis: Util.seconds_since_epoch * 1000
    }
  end
end
