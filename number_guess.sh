#!/bin/bash

# PSQL variable for querying the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for the username
echo "Enter your username:"
read USERNAME

# Check if the username exists in the database
USER_INFO=$($PSQL "SELECT user_id, username, games_played, best_game FROM users WHERE username='$USERNAME'")

# If the user exists in the database
if [[ -n $USER_INFO ]]
then
  # Parse user information from the database
  IFS="|" read USER_ID DB_USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  
  # Welcome the returning user and display their stats
  echo "Welcome back, $DB_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  # If the user is new, insert them into the database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  
  # After inserting the new user, retrieve the user ID and initialize stats
  USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")
  IFS="|" read USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  
  # Welcome the new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

# Generate the secret random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Start the game
echo "Guess the secret number between 1 and 1000:"

# Initialize guess count
NUMBER_OF_GUESSES=0

# Loop until the user guesses the correct number
while [[ $GUESSED_NUMBER != $SECRET_NUMBER ]]
do
  read GUESSED_NUMBER
  
  # Check if the input is an integer
  if ! [[ $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    ((NUMBER_OF_GUESSES++))
    
    # Give feedback if the guess is too high or too low
    if [[ $GUESSED_NUMBER -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $GUESSED_NUMBER -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    fi
  fi
done

# When the user guesses the correct number
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# Update the user's stats in the database
GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

# Update the best game if this is the user's best game or if they don't have a best game yet
if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  BEST_GAME=$NUMBER_OF_GUESSES
fi

# Update the users table with the new games played count and best game
UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE user_id=$USER_ID")

# End of the script
