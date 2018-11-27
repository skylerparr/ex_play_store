defmodule ExPlayStore.PurchaseVerification do
  use Injector

  alias ExPlayStore.PurchaseReceipt
  alias ExPlayStore.ErrorPurchaseReceipt

  inject ExPlayStore.OAuthToken
  inject Tesla

  @url [
    base: "https://www.googleapis.com/androidpublisher/v2/applications/",
    package_name: "",
    mid: "/purchases/products/",
    product_id: "",
    last: "/tokens/",
    token: ""
  ]

  @spec fetch_receipt(String.t, String.t, String.t) :: %PurchaseReceipt{} | %ErrorPurchaseReceipt{}
  def fetch_receipt(package_name, product_id, token) do
    auth_token = OAuthToken.get()
    headers = ["Authorization": "Bearer " <> auth_token.access_token]
    
    @url
    |> Keyword.update(:package_name, nil, fn(_) -> package_name end)
    |> Keyword.update(:product_id, nil, fn(_) -> product_id end)
    |> Keyword.update(:token, nil, fn(_) -> token end)
    |> Keyword.values
    |> Enum.join("")
    |> Tesla.get([headers: headers])
    |> Map.get(:body)
    |> Poison.decode!
    |> as_struct()
  end

  defp as_struct(%{
      "consumptionState" => consumption_state,
      "developerPayload" => developer_payload,
      "kind" => kind,
      "purchaseState" => purchase_state,
      "purchaseTimeMillis" => purchase_time_millis,
    }) do
    %PurchaseReceipt{
      consumption_state: consumption_state,
      developer_payload: developer_payload,
      kind: kind,
      purchase_state: purchase_state,
      purchase_time_millis: purchase_time_millis
    }
  end

  defp as_struct(%{"error" => %{
        "code" => 400, "errors" =>
          [%{"domain" => domain, "message" => message, "reason" => reason}],
    "message" => "Invalid Value"}}
    ) do
    %ErrorPurchaseReceipt{
      domain: domain,
      message: message,
      reason: reason
    }
  end
end
