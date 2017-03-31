defmodule ExPlayStore.Util do
  @one_hour 3600

  def seconds_since_epoch do
    :os.system_time(:seconds)
  end

  def one_hour_from_now do
    seconds_since_epoch() + @one_hour
  end
end
