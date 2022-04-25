defmodule RecentOpponents.FetchRecentOpponentsTest do
  use ExUnit.Case
  doctest RecentOpponents
  alias RecentOpponents.FetchRecentOpponents
  alias RecentOpponents.TestData

  test "FetchRecentOpponents.fetch_recent_opponents" do
    api_key = System.get_env("LEAGUE_API_KEY")

    recent_opponents = FetchRecentOpponents.fetch_recent_opponents(TestData.test_name, TestData.test_region, api_key)

    assert is_list(recent_opponents)
    assert Enum.member?(Map.keys(List.first(recent_opponents)), :name)
    assert !Enum.member?(Enum.map(recent_opponents, fn opp -> opp.name end),  TestData.test_name)
  end

end
