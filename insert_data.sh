#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Build complete SQL script and execute it
$PSQL "$(
  echo "BEGIN;"
  
  # Insert all unique teams
  tail -n +2 games.csv | cut -d',' -f3,4 | tr ',' '\n' | sort -u | while read team
  do
    team_escaped=$(printf '%s\n' "$team" | sed "s/'/''/g")
    echo "INSERT INTO teams(name) VALUES('$team_escaped') ON CONFLICT DO NOTHING;"
  done
  
  # Insert all games
  tail -n +2 games.csv | while IFS=',' read -r year round winner opponent winner_goals opponent_goals
  do
    round_escaped=$(printf '%s\n' "$round" | sed "s/'/''/g")
    winner_escaped=$(printf '%s\n' "$winner" | sed "s/'/''/g")
    opponent_escaped=$(printf '%s\n' "$opponent" | sed "s/'/''/g")
    
    echo "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) SELECT $year, '$round_escaped', (SELECT team_id FROM teams WHERE name='$winner_escaped'), (SELECT team_id FROM teams WHERE name='$opponent_escaped'), $winner_goals, $opponent_goals;"
  done
  
  echo "COMMIT;"
)"
