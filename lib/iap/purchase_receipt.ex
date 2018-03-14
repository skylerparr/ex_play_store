defmodule ExPlayStore.PurchaseReceipt do
  defstruct consumption_state: nil,
            developer_payload: nil,
            kind: nil, 
            purchase_state: nil,
            purchase_time_millis: nil  
end

defmodule ExPlayStore.ErrorPurchaseReceipt do
  defstruct domain: nil,
            message: nil,
            reason: nil
end
