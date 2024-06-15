#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
MENU() {
  SERVICE_LIST=$($PSQL "select service_id, name from services order by service_id;")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED

  SERVICE_ID_SELECTED_RESULT=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_SELECTED_RESULT ]]
  then
    MENU
  else
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]] 
    then
      echo -e "\nWhat is your name?"
      read CUSTOMER_NAME
      NEW_CUSTOMER_RESULT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    echo -e "\nWhat time do you want your appointment to be?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
    NEW_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

    SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
    echo "I have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
  fi
}

MENU
