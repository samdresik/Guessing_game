#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN()
{
  #ask for name
  echo Enter your username:
  read USERNAME
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
    #if username doesn't exist
    if [[ -z $USER_ID ]]
      then
      echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
      INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
      
      else
      #if username is in the table
      GAMES_PLAYED=$($PSQL "SELECT COUNT(user_id) FROM games WHERE user_id = $USER_ID")
      BEST_GAME=$($PSQL "SELECT MIN(number_of_tries) FROM games WHERE user_id = $USER_ID")
      echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
  GUESS
}

GUESS()
{
UNKNOWN=$((1 + $RANDOM % 1000))
echo -e "\nGuess the secret number between 1 and 1000:"
read TRY

GUESSED=0
GUESS_TRIES=0

while [[ $GUESSED != 1 ]]
do
  if [[ $TRY =~ ^[0-9]+$ ]]
    then
    GUESS_TRIES=$(($GUESS_TRIES + 1))
      if [[ $TRY < $UNKNOWN ]]
       then
       echo -e "\nIt's higher than that, guess again:"
       read TRY
      elif [[ $TRY > $UNKNOWN ]]
        then
        echo -e "\nIt's lower than that, guess again:"
       read TRY
      elif [[ $TRY = $UNKNOWN ]]
       then
       GUESSED=1
       INSERT_GUESS_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_tries) VALUES($USER_ID, $GUESS_TRIES)")
       echo -e "\nYou guessed it in $GUESS_TRIES tries. The secret number was $UNKNOWN. Nice job!"
      fi
  else
  echo -e "\nThat is not an integer, guess again:"
  read TRY
  fi
  done
}

MAIN
