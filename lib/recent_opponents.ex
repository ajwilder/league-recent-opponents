defmodule RecentOpponents do

  def fetch_recent_opponents(summoner_name \\ "SwordArt", region \\ "americas")
  def fetch_recent_opponents(summoner_name, region) do
    api_key = System.get_env "LEAGUE_API_KEY"

    url = "https://#{region}.api.riotgames.com/lol/summoner/v4/summoners/by-name/#{summoner_name}?api_key=#{api_key}"

    IO.puts url
  end

end
