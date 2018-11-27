defmodule ExPlayStore.TeslaClient do
  use Tesla

  def client() do
    Tesla.client(
      [],
      {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}
    )
  end

end
