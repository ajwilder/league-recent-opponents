defmodule RecentOpponents.SummonerMonitor do
  use GenServer

  alias RecentOpponents.APIQueries

  @one_minute 60_000

  def start_link(data) do
    GenServer.start_link(__MODULE__, data)
  end

  def init(data = %{summoner: _summoner, region: _region, api_key: _api_key}) do
    Process.send_after(self(), :init_monitoring, 1)
    {:ok, data}
  end

  def handle_info(:init_monitoring, state = %{summoner: %{puuid: puuid}, api_key: api_key, region: region}) do
    case APIQueries.get_summoners_last_n_match_ids_by_puuid(puuid, 1, api_key, region) do
      {:error, reason} ->
        Process.send_after(self(), :init_monitoring, @one_minute)
        IO.puts "error initializing SummonerMonitor for user #{puuid} because: #{reason}.  Will retry in 1 minute"
        {:noreply, state}
      match_ids ->
        last_match = List.first(match_ids)
        Process.send_after(self(), :check_for_new_matches, @one_minute)
        state = Map.merge(state, %{count: 0, last_match: last_match})
        {:noreply, state}
    end
  end

  def handle_info(:check_for_new_matches, state = %{summoner: %{puuid: puuid}, api_key: api_key, count: count, last_match: last_match, region: region}) do
    new_count = count + 1

    if new_count != 60 do
      Process.send_after(self(), :check_for_new_matches, @one_minute)
    end

    case APIQueries.get_summoners_last_n_match_ids_by_puuid(puuid, 2, api_key, region) do
      {:error, reason} ->
        case new_count do
          60 ->
            IO.puts "error final check_for_new_matches: #{reason} #{puuid}"
            {:stop, :normal, state}
          _ ->
            IO.puts "error check_for_new_matches: #{reason} #{puuid}"
            IO.puts "retry in 1 minute"
            state = Map.put(state, :count, new_count)
            {:noreply, state}
        end
      two_most_recent_matches ->
        state = process_new_match_data(two_most_recent_matches, state)

        case new_count do
          60 ->
            {:stop, :normal, state}
          _ ->
            state = Map.put(state, :count, new_count)
            {:noreply, state}
        end
    end

  end

  def process_new_match_data([match0], state), do: state

  def process_new_match_data([match0, _], state = %{last_match: last_match}) when match0 == last_match do
    state
  end
  def process_new_match_data([match0, match1], state = %{summoner: %{name: name}, last_match: last_match}) when match1 == last_match do
    IO.puts "Summoner #{name} completed match #{match0}"
    Map.put(state, :last_match, match0)
  end
  def process_new_match_data(matches = [match0, _], state = %{summoner: %{name: name}, last_match: last_match}) do
    new_matches = get_matches_until_last(matches, state)
    Enum.each(matches, fn match ->
      if match != last_match do
        IO.puts "Summoner #{name} completed match #{match}"
      end
    end)
    Map.put(state, :last_match, match0)
  end

  def get_matches_until_last(matches, state = %{summoner: %{puuid: puuid}, last_match: last_match, api_key: api_key, region: region}) do
    offset = length(matches)
    [next_match] = APIQueries.get_summoners_last_n_match_ids_by_puuid(puuid, 1, api_key, region, offset)

    matches = List.flatten([matches | next_match])
    case last_match == next_match do
      true ->
        matches
      false ->
        get_matches_until_last(matches, state)
    end
  end

end
