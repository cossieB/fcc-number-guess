#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

# NUMBER=$(( $RANDOM % 1000 + 1 ))
NUMBER=40
COUNT=1

echo "Enter your username:"
read USERNAME

USERNAME_QUERY_RESULT=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME';")

if [[ -z $USERNAME_QUERY_RESULT ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME');")

else 
  JOIN_RESULT=$($PSQL "SELECT COUNT(*), MIN(guesses) FROM games INNER JOIN users USING(username) WHERE username = '$USERNAME';")
  echo $JOIN_RESULT | while read NUM_GAMES BAR HISCORE
  do
    echo "Welcome back, $USERNAME! You have played $NUM_GAMES games, and your best game took $HISCORE guesses."
  done
fi

echo Guess the secret number between 1 and 1000:
read GUESS

until (( $GUESS == $NUMBER ))
do
  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo That is not an integer, guess again:
    read GUESS
  done

if (( GUESS < NUMBER )); then
  echo "It's higher than that, guess again:"
elif (( GUESS > NUMBER )); then
  echo "It's lower than that, guess again:"
fi
(( ++COUNT ))
read GUESS
done

echo "You guessed it in $COUNT tries. The secret number was $NUMBER. Nice job!"

INSERT_SCORE=$($PSQL "INSERT INTO games (username, guesses) VALUES ('$USERNAME', $COUNT)")
