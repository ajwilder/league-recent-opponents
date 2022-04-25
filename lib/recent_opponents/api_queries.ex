defmodule RecentOpponents.APIQueries do

  def get_summoner_by_name(name, region, api_key) do
    get_summoner_url = "https://#{region}.api.riotgames.com/lol/summoner/v4/summoners/by-name/#{name}?api_key=#{api_key}"
    {:ok, %{body: body}} = HTTPoison.get(get_summoner_url)
    case Jason.decode(body) do
      {:ok, %{"status" => %{"status_code" => 403}}} ->
        {:error, "Forbidden"}
      {:ok, %{"status" => %{"status_code" => 429}}} ->
        {:error, "Rate limit Exceeded"}
      {:ok, summoner_data} ->
        summoner_data
    end
  end

  def get_summoners_last_n_match_ids_by_puuid(puuid, count, api_key, summoner_region, start \\ 0, retrying? \\ false) do
    match_region = get_match_region_by_summoner_region(summoner_region)

    get_summoner_matches_url = "https://#{match_region}.api.riotgames.com/lol/match/v5/matches/by-puuid/#{puuid}/ids?api_key=#{api_key}&count=#{count}&start=#{start}"

    {:ok, %{body: body}} = HTTPoison.get(get_summoner_matches_url)

    case Jason.decode(body) do
      {:ok, %{"status" => %{"status_code" => 403}}} ->
        {:error, "Forbidden"}
      {:ok, %{"status" => %{"status_code" => 429}}} ->
        case retrying? do
          true ->
            {:error, "Rate limit Exceeded"}
          false ->
            :timer.sleep(1000)
            get_summoners_last_n_match_ids_by_puuid(puuid, count, api_key, summoner_region, start, true)
        end
      {:ok, match_ids} ->
        match_ids
    end
  end

  def get_match_by_match_id(match_id, api_key, summoner_region) do
    match_region = get_match_region_by_summoner_region(summoner_region)

    get_match_url = "https://#{match_region}.api.riotgames.com/lol/match/v5/matches/#{match_id}?api_key=#{api_key}"

    {:ok, %{body: body}} = HTTPoison.get(get_match_url)
    case Jason.decode(body) do
      {:ok, %{"status" => %{"status_code" => 403}}} ->
        {:error, "Forbidden"}
      {:ok, match} ->
        match
    end
  end

  defp get_match_region_by_summoner_region(summoner_region) do
    String.replace(summoner_region, ~r/[^\D]/, "")
    |> String.downcase()
    |> parse_match_region()
  end

  defp parse_match_region("na"), do: "americas"
  defp parse_match_region("oce"), do: "americas"
  defp parse_match_region("las"), do: "americas"
  defp parse_match_region("lan"), do: "americas"
  defp parse_match_region("br"), do: "americas"
  defp parse_match_region("kr"), do: "asia"
  defp parse_match_region("jp"), do: "asia"
  defp parse_match_region("eune"), do: "europe"
  defp parse_match_region("euw"), do: "europe"
  defp parse_match_region("tr"), do: "europe"
  defp parse_match_region("ru"), do: "europe"

end
