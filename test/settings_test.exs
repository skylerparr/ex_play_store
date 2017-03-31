defmodule ExPlayStore.SettingsTest do
  use ExUnit.Case, async: true
  import Mocker

  alias ExPlayStore.Settings

  setup do
    mock(EnvConfig)
    mock(File)
    :ok
  end

  test "should get private key string" do
    intercept(EnvConfig, :get, [:ex_play_store, :private_key], with: fn(_,_) ->
      "bobloblaw"
    end)
    assert "bobloblaw" == Settings.private_key
  end

  test "should get private key from path" do
    intercept(EnvConfig, :get, [:ex_play_store, :private_key_path], with: fn(_,_) ->
      "/path/to/private_key"
    end)
    intercept(File, :read, ["/path/to/private_key"], with: fn(_) ->
      "bobloblaw"
    end)

    assert "bobloblaw" == Settings.private_key
  end

  test "should get private key from json file path" do
    intercept(EnvConfig, :get, [:ex_play_store, :private_key_json], with: fn(_,_) ->
      "/path/to/private_key.json"
    end)
    intercept(File, :read, ["/path/to/private_key.json"], with: fn(_) ->
      sample_json_string()
    end)

   assert "bobloblaw" == Settings.private_key
  end

  test "should get the client email from a string" do
    intercept(EnvConfig, :get, [:ex_play_store, :client_email], with: fn(_,_) ->
      "bobloblaw@bobloblaw-839402.iam.gserviceaccount.com"
    end)

    assert "bobloblaw@bobloblaw-839402.iam.gserviceaccount.com" == Settings.client_email
  end

  test "should get the client email from json file path" do
    intercept(EnvConfig, :get, [:ex_play_store, :private_key_json], with: fn(_,_) ->
      "/path/to/private_key.json"
    end)
    intercept(File, :read, ["/path/to/private_key.json"], with: fn(_) ->
      sample_json_string()
    end)

    assert "bobloblaw@bobloblaw-839402.iam.gserviceaccount.com" == Settings.client_email
  end

  test "should get a single string of scopes" do
    intercept(EnvConfig, :get, [:ex_play_store, :scopes], with: fn(_,_) ->
      "https://www.googleapis.com/auth/analytics.readonly"
    end)
    
    assert "https://www.googleapis.com/auth/analytics.readonly" == Settings.scopes
  end

  test "should get space separated string if provided a list of scopes" do
    intercept(EnvConfig, :get, [:ex_play_store, :scopes], with: fn(_,_) ->
      ["https://www.googleapis.com/auth/analytics.readonly", "https://www.googleapis.com/auth/androidpublisher"]
    end)
    
    assert "https://www.googleapis.com/auth/analytics.readonly https://www.googleapis.com/auth/androidpublisher" == Settings.scopes
  end

  defp sample_json_string do
		%{"auth_provider_x509_cert_url" => "https://www.googleapis.com/oauth2/v1/certs",                          
			"auth_uri" => "https://accounts.google.com/o/oauth2/auth",
			"client_email" => "bobloblaw@bobloblaw-839402.iam.gserviceaccount.com",
			"client_id" => "3948320483",
			"client_x509_cert_url" => "https://www.googleapis.com/robot/v1/metadata/x509/bobloblaw-8329.iam.gserviceaccount.com",
			"private_key" => "bobloblaw",
			"private_key_id" => "private_lob_key",
			"project_id" => "project_id",
			"token_uri" => "https://accounts.google.com/o/oauth2/token",
			"type" => "service_account"}
		|> Poison.encode!
  end
end
