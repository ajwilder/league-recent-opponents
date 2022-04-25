defmodule RecentOpponents do
  alias __MODULE__.FetchRecentOpponents
  alias __MODULE__.SummonerMonitor

  def fetch_and_monitor_recent_opponents(summoner_name  \\ "SwordArt", summoner_region \\ "na1") do
    api_key = System.get_env("LEAGUE_API_KEY")

    case FetchRecentOpponents.fetch_recent_opponents(summoner_name, summoner_region, api_key) do
      {:error, reason = "Rate limit Exceeded"} ->
        IO.puts "Failed because '#{reason}.'  Try again later."
      {:error, reason} ->
        IO.puts "Failed because '#{reason}.'"
      recent_opponents ->
        Enum.each(recent_opponents, fn opponent ->
          data = %{
            summoner: opponent,
            region: summoner_region,
            api_key: api_key
          }
          {:ok, _pid} = SummonerMonitor.start_link(data)
        end)

        Enum.map(recent_opponents, fn opponent -> opponent[:name] end)
    end
  end




end
