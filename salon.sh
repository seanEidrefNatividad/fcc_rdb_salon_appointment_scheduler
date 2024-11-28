#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT service_id,name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
  echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  SERVICE_VALIDATION
}
SERVICE_VALIDATION() {
  read SERVICE_ID_SELECTED
  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
   MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_ID_SELECTED_RESULT=$($PSQL "SELECT service_id,name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_SELECTED_RESULT ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      SET_APPOINTMENT $SERVICE_ID_SELECTED
    fi
  fi
}
SET_APPOINTMENT() {
  # echo service id: $1
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$1")
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$1,'$SERVICE_TIME')")

  if [[ -z $INSERT_APPOINTMENT_RESULT ]]
  then
    echo -e "\nError: could not set apppointment."
  else
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
  fi
} 
MAIN_MENU