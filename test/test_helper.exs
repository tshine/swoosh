if Application.fetch_env!(:swoosh, :api_client) == Swoosh.ApiClient.Finch do
  Finch.start_link(name: Swoosh.Finch)
end

ExUnit.start()
ExUnit.configure(exclude: :integration)

Application.ensure_all_started(:bypass)
