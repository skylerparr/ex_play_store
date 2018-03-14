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
    headers = %{"Authorization" => "Bearer 34lksjva30d"}

    sample_receipt = sample_receipt()
    consumed = consumed_receipt()

    intercept(Tesla, :get, ["https://www.googleapis.com/androidpublisher/v2/applications/com.example/purchases/products/fire.sale/tokens/09vuisohj", [headers: headers]], with: fn(_,_) ->
      %{body: sample_receipt |> Poison.encode!}
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
    headers = %{"Authorization" => "Bearer 34lksjva30d"}

    sample_receipt = sample_failure()
    intercept(Tesla, :get, ["https://www.googleapis.com/androidpublisher/v2/applications/com.example/purchases/products/fire.sale/tokens/09vuisohj", [headers: headers]], with: fn(_,_) ->
      %{body: sample_receipt |> Poison.encode!}
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
