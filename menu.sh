#!/bin/bash
source ./.env

Pause()
{
    echo ""
    read -p "Press [Enter] key to continue..." fackEnterKey
}

StartMessage()
{
    clear
    echo "Starting CPS510 Oracle Database Menu Tool..."
}

MainMenu()
{
    while [ "$CHOICE" != "START" ]
    do
        clear
        echo "================================================================="
        echo "| Oracle All Inclusive Tool                                     |"
        echo "| Main Menu - Select Desired Operation(s):                      |"
        echo "| <CTRL-Z Anytime to Enter Interactive CMD Prompt>              |"
        echo "-----------------------------------------------------------------"
        echo " $IS_SELECTEDM M) View Manual"
        echo " "
        echo " $IS_SELECTED1 1) Drop Tables"
        echo " $IS_SELECTED2 2) Create Tables"
        echo " $IS_SELECTED3 3) Populate Tables"
        echo " $IS_SELECTED4 4) Query Tables"
        echo " "
        echo " $IS_SELECTEDX X) Force/Stop/Kill Oracle DB"
        echo " "
        echo " $IS_SELECTEDE E) End/Exit"
        echo "Choose: "
        read CHOICE

        if [ "$CHOICE" == "0" ]
        then
            echo "Nothing Here"
            Pause
        elif [ "$CHOICE" == "M" ] || [ "$CHOICE" == "m" ]
        then
            echo "CPS510 Car Rental Management System - Select 1-4 to manage schema and run queries."
            Pause
        elif [ "$CHOICE" == "1" ]
        then
            bash drop_tables.sh
            Pause
        elif [ "$CHOICE" == "2" ]
        then
            bash create_tables.sh
            Pause
        elif [ "$CHOICE" == "3" ]
        then
            bash populate_tables.sh
            Pause
        elif [ "$CHOICE" == "4" ]
        then
            bash queries.sh
            Pause
        elif [ "$CHOICE" == "E" ] || [ "$CHOICE" == "e" ]
        then
            echo "Exiting Oracle All Inclusive Tool..."
            exit 0
        fi
    done
}

#--COMMENTS BLOCK--
# Main Program
#--COMMENTS BLOCK--
ProgramStart()
{
    StartMessage
    while [ 1 ]
    do
        MainMenu
    done
}

ProgramStart
