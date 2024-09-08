#!/bin/bash

# PSQL command to interact with the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for the username
echo "Enter your username:"
read USERNAME

# Check if the user exists in the database
USER_INFO=$($PSQL "SELECT user_id, username, games_played, best_game FROM users WHERE username='$USERNAME'")

# If user exists
if [[ -n $USER_INFO ]]
then
  # Parse user info
  IFS="|" read USER_ID DB_USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $DB_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  # If user doesn't exist, insert into users table
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Get new user info
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  GAMES_PLAYED=0
  BEST_GAME=null
fi

# Randomly generate the secret number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Start the guessing game
echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0

while [[ $GUESSED_NUMBER != $SECRET_NUMBER ]]
do
  read GUESSED_NUMBER

  # Ensure the input is an integer
  if ! [[ $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    ((NUMBER_OF_GUESSES++))
    
    # Provide feedback on the guess
    if [[ $GUESSED_NUMBER -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $GUESSED_NUMBER -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    fi
  fi
done

# When guessed correctly
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# Update the user's games_played and best_game in the database
GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  BEST_GAME=$NUMBER_OF_GUESSES
fi

UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE user_id=$USER_ID")

# Optional: Insert the game into the games table
# INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")

# Optional: Insert the game into the games table
# INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")

# Optional: Insert the game into the games table
# INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")

# Optional: Insert the game into the games table
# INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")