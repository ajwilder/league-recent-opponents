# RecentOpponents

This app uses the Riot Games API to monitor players' activity on League of Legends.  Given a valid summoner_name and region, RecentOpponents will fetch all summoners this summoner has played with in the last 5 matches. This data is returned to the caller as a list of summoner names formatted as a list of strings. Also, the following occurs:
1. Once fetched, all summoners will be monitored for new matches every minute for the next hour
2. When a summoner plays a new match, the match id is logged to the console, such as: "Summoner <summoner name> completed match <match id>"

## Installation

### API Key
This mix project needs a valid Riot Games API Key to function.  Store this as an environment variable named LEAGUE_API_KEY.  
export LEAGUE_API_KEY=