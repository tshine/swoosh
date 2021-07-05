defmodule Swoosh.ApiClient.Finch do
  @moduledoc """
  Finch-based ApiClient for Swoosh.

  In order to use `Finch` API client, you must start `Finch` and provide a :name.
  Often in your supervision tree:

      children = [
        {Finch, name: Swoosh.Finch}
      ]

  Or, in rare cases, dynamically:

      Finch.start_link(name: Swoosh.Finch)
  """

  require Logger

  @behaviour Swoosh.ApiClient
  @user_agent {"User-Agent", "swoosh/#{Swoosh.version()}"}

  @impl true
  def init do
    unless Code.ensure_loaded?(Finch) do
      Logger.error("""
      Could not find finch dependency.

      Please add :finch to your dependencies:

          {:finch, "~> 0.8"}

      Or set your own Swoosh.ApiClient:

          config :swoosh, :api_client, MyAPIClient
      """)

      raise "missing finch dependency"
    end

    _ = Application.ensure_all_started(:finch)
    :ok
  end

  @impl true
  def post(url, headers, body, %Swoosh.Email{} = email) do
    url = IO.iodata_to_binary(url)
    request = Finch.build(:post, url, [@user_agent | headers], body)
    options = email.private[:client_options] || []

    case Finch.request(request, Swoosh.Finch, options) do
      {:ok, response} ->
        {:ok, response.status, response.headers, response.body}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
