#! /bin/bash
echo -e "\n~~~~~ FCC Beauty Salon ~~~~~\n"
PSQL="psql --username=freecodecamp --dbname=salon -t -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR NAME
  do
    echo -e "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_FOUND=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ -z $SERVICE_FOUND ]] 
    then
      MAIN_MENU "Invalid service ID. Please choose a valid ID from the list."
    else
      echo -e "\nYou selected service ID $SERVICE_ID_SELECTED. What is your phone number?\n"
      read CUSTOMER_PHONE

      CUSTOMER_PHONE_SELECTED=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      if [[ -z $CUSTOMER_PHONE_SELECTED ]]
      then
        echo -e "\nYou must be new! What is your name?\n"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        echo -e "\nHello $CUSTOMER_NAME!\n"
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers where phone = '$CUSTOMER_PHONE'")
        echo -e "\nWelcome back $CUSTOMER_NAME!\n"
      fi

      echo -e "\nEnter a time for the appointment:\n"
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL  "SELECT customer_id FROM customers where phone = '$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      if [[ $INSERT_APPOINTMENT_RESULT = "INSERT 0 1" ]]
      then
        SERVICE_NAME=$($PSQL "SELECT name FROM services where service_id=$SERVICE_ID_SELECTED")
        echo "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ //') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ //')."
      fi
    fi
  else
    MAIN_MENU "Invalid input. Please choose a valid ID from the list."
  fi
}
MAIN_MENU