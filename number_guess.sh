#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=game_db -t --no-align -c"


RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

echo Enter your username:
read USER_NAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USER_NAME';") 
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME');")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USER_NAME';") 
else
  TOTAL_GAMES=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID;") 
  BEST_GAME=$($PSQL "SELECT MIN(total_attempts) FROM games WHERE user_id = $USER_ID;") 
  echo "Welcome back, $USER_NAME! You have played $TOTAL_GAMES games, and your best game took $BEST_GAME guesses."
fi
echo Guess the secret number between 1 and 1000:
COUNT_TRY=1
NUMBER_TRY=0
while [[ $NUMBER_TRY != $RANDOM_NUMBER ]]
do
  read NUMBER_TRY
  if [[ "$NUMBER_TRY" =~ ^[0-9]+$ ]]
  then
    if [[ $NUMBER_TRY -lt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      COUNT_TRY=$(( COUNT_TRY + 1 ))
    else
      if [[ $NUMBER_TRY -gt $RANDOM_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
        COUNT_TRY=$(( COUNT_TRY + 1 ))
      fi
    fi
  else
    echo That is not an integer, guess again:
  fi
done
echo You guessed it in $COUNT_TRY tries. The secret number was $RANDOM_NUMBER. Nice job!
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, total_attempts) VALUES($USER_ID, $COUNT_TRY);")