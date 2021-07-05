if Application.fetch_env!(:swoosh, :api_client) == Swoosh.ApiClient.Finch do
  Application.put_env(:swoosh, :finch_name, Swoosh.Test.Finch)
  Finch.start_link(name: Swoosh.Test.Finch)
end

ExUnit.start()
ExUnit.configure(exclude: :integration)

Application.ensure_all_started(:bypass)
