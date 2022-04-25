defmodule RecentOpponents.FetchRecentOpponents do
  alias RecentOpponents.APIQueries

  def fetch_recent_opponents(summoner_name, summoner_region, api_key) do

    case APIQueries.get_summoner_by_name(summoner_name, summoner_region, api_key) do
      {:error, reason} ->
        {:error, reason}
      %{"puuid" => puuid} ->
        match_ids = APIQueries.get_summoners_last_n_match_ids_by_puuid(puuid, 5, api_key, summoner_region)

        Enum.map(match_ids, fn match_id ->
          get_summoner_names_by_match_id(match_id, api_key, summoner_region)
        end)
        |> List.flatten
        |> List.delete(puuid)
        |> Enum.uniq
    end
  end

  def get_summoner_names_by_match_id(match_id, api_key, summoner_region) do
    %{"info" => %{"participants" => participants}} = APIQueries.get_match_by_match_id(match_id, api_key, summoner_region)
    Enum.map(participants, fn participant -> %{name: participant["summonerName"], puuid: participant["puuid"]} end)
  end

end
