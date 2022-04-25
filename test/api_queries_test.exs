defmodule RecentOpponents.APIQueriesTest do
  use ExUnit.Case
  doctest RecentOpponents
  alias RecentOpponents.APIQueries
  alias RecentOpponents.TestData

  test "APIQueries.get_summoner_by_name" do
    api_key = System.get_env("LEAGUE_API_KEY")

    summoner_data = APIQueries.get_summoner_by_name(TestData.test_name, TestData.test_region, api_key)

    assert Enum.member?(Map.keys(summoner_data), "puuid")
    assert summoner_data["puuid"] == TestData.test_puuid
  end

  test "APIQueries.get_summoners_last_n_match_ids_by_puuid" do
    api_key = System.get_env("LEAGUE_API_KEY")

    last_three_matches = APIQueries.get_summoners_last_n_match_ids_by_puuid(TestData.test_puuid, 3, api_key, TestData.test_region)
    last_two_matches = APIQueries.get_summoners_last_n_match_ids_by_puuid(TestData.test_puuid, 2, api_key, TestData.test_region)
    last_match = APIQueries.get_summoners_last_n_match_ids_by_puuid(TestData.test_puuid, 1, api_key, TestData.test_region)

    assert length(last_three_matches) == 3
    assert length(last_two_matches) == 2
    assert length(last_match) == 1
  end

  test "APIQueries.get_match_by_match_id" do
    api_key = System.get_env("LEAGUE_API_KEY")

    match = APIQueries.get_match_by_match_id(TestData.match_id, api_key, TestData.test_region)

    assert Enum.member?(Map.keys(match), "info")
    assert Enum.member?(Map.keys(match["info"]), "participants")
  end

end
