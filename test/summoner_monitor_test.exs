defmodule RecentOpponents.SummonerMonitorTest do
  use ExUnit.Case
  doctest RecentOpponents
  alias RecentOpponents.SummonerMonitor
  alias RecentOpponents.APIQueries
  alias RecentOpponents.TestData

  test "SummonerMonitor.process_new_match_data" do

    state_1 = %{test: true}
    assert SummonerMonitor.process_new_match_data(["test_match_1"], state_1) == state_1

    state_2 = %{summoner: %{name: TestData.test_name}, last_match: "test_match_1"}
    assert SummonerMonitor.process_new_match_data(["test_match_1", "test_match_2"], state_2) == state_2

    init_state_3 = %{summoner: %{name: TestData.test_name}, last_match: "test_match_2"}
    end_state_3 = %{summoner: %{name: TestData.test_name}, last_match: "test_match_1"}
    assert SummonerMonitor.process_new_match_data(["test_match_1", "test_match_2"], init_state_3) == end_state_3

  end

  test "SummonerMonitor.check_for_new_matches" do
    api_key = System.get_env("LEAGUE_API_KEY")
    puuid = TestData.test_puuid
    region = TestData.test_region

    last_1_matches = APIQueries.get_summoners_last_n_match_ids_by_puuid(puuid, 1, api_key, region)
    assert length(last_1_matches) == 1

    last_match = List.first(last_1_matches)
    assert is_binary(last_match)

    state_1 = %{
      summoner: %{puuid: puuid},
      api_key: api_key,
      count: 1,
      last_match: last_match,
      region: region
    }
    new_state_1 = Map.put(state_1, :count, 2)

    assert SummonerMonitor.handle_info(:check_for_new_matches, state_1) == {:noreply, new_state_1}

    state_2 = Map.put(state_1, :count, 59)

    assert SummonerMonitor.handle_info(:check_for_new_matches, state_2) == {:stop, :normal, state_2}

  end

  test "SummonerMonitor.init_monitoring" do
    api_key = System.get_env("LEAGUE_API_KEY")
    puuid = TestData.test_puuid
    region = TestData.test_region

    state = %{
      summoner: %{puuid: puuid},
      api_key: api_key,
      region: region
    }

    {:noreply, initialized_state} = SummonerMonitor.handle_info(:init_monitoring, state)

    assert initialized_state[:count] == 0
    assert is_binary(initialized_state[:last_match])

  end

end
