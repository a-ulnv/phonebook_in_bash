#!/bin/bash

# Author: Alexander Ulyanov
# Title: Final Project for CM325 Class

# Trap ------------------------------------
pb_exit(){
	echo "Now exiting ..."
	rm /tmp/hold*.$$
}

trap 'pb_exit; exit' SIGINT SIGQUIT SIGTERM

# -----------------------------------------


# Show the title of the program
PROGTITLE="================ Phonebook in BASH ================"
echo $PROGTITLE

# Locate the file
echo -n 'What phone directory file to use? '
read userfile


# Function to check how many rows in the file
# Checks how many rows on the line
# Checks if the number of rows on every line is the same
function checkrows(){

	numlines=$(wc -l $1 | cut -f1 -d' ')
	numcols=`awk "NR==1 {print NF}" $1`

	if [ ! "$numcols" -eq "3" ] ; then
		echo "The $c file does not contain a configuration consistent with a phone book"
		exit
	fi 

	for (( c=2; c<=$numlines; c++ ))
	do
		cols=`awk "NR==$c {print NF}" $1` 
		if [ ! "$numcols" -eq "$cols" ] ; then
			echo "Not equal number of columns on the lines in line number $c"
			exit
		fi
	done

}

# Check the contacts file
if [ ! -e $userfile ] ; then
	echo 'ERROR: File does not exist'
	exit
elif [ ! -f $userfile ] ; then
	echo 'ERROR: File is not regular'
	exit
elif [ ! -s $userfile ] ; then
	echo 'ERROR: File is zero-size'
else 
	checkrows $userfile
fi

# Menu functions
function findentry(){
	grep $1 $2
}

# Add an entry to the phone book
function addentry(){
	if checkusername ; then
		echo "Please enter fist name, followed by the tab, then last name, followed by the tab, then phone number in XXX-XXXX format"
		echo "Example:"
		echo "John	Smith	555-5555"
		read newentry
		numcols=`echo "$newentry" | awk -F"\t" '{print NF}'`
		if [ "$numcols" -eq "3" ] ; then
			echo $newentry >> $1
			echo "The recod $newentry was added"
		else
			echo "The new entry does not match the format of the phone book"
			echo "Nothing was entered"
		fi
	fi
}

# Delete the entry from the phone book
# Format: deleteentry [Argument] [Phone book file]
function deleteentry(){
	if checkusername ; then
		entry=`findentry $1 $2`
		if [ ! -z "$entry" ] ; then
			read -p "Do you want to delete $entry ?" yn
			case $yn in
				[Yy]* ) sed -i "/$entry/d" $2
					echo "The record $entry was deleted"
					;;
				[Nn]* ) ;;
				* ) echo "Please answer yes or no"
					;;
			esac
		fi
	fi
}

# Modify an entry in the phone book
function modifyentry(){
	if checkusername ; then
		oldentry=`findentry $1 $2`
		echo "Entry found: $oldentry"
		echo "Enter the modified entry:"
		read newentry
		read -p "Do you want to substiture $oldentry with $newentry ?" yn
		case $yn in
			[Yy]* ) sed -i "s/$oldentry/$newentry/" "$2" ;;
			[Nn]* ) ;;
			* ) echo "Please answer yes or no" ;;
		esac
	fi
}

# Menu
while [ menuanswer != "0" ]
do

	clear

	# Menu map
    echo $PROGTITLE
	echo "Select from the following options"
	echo "	A	Add an entry to the book"
	echo "	D	Delete an entry from the book"
	echo "	M	Modify an entry in the phone book"
	echo "	I	Display an entry in the phone book"
	echo "	P	Display all entries in sorted order"
	echo "	X	Exit the program"
	
	# Receive the input
	read  menuanswer

	# Process the input
	case  $menuanswer in
		A|a) echo "You selected to add an entry to the phone book"
			addentry $userfile
			;;
		D|d) echo "You selected to delete the entry from the phone book"
			echo "Enter the name OR the phone number of the entry you want to DELETE"
			read entrytodelete
			deleteentry $entrytodelete $userfile
			;;
		M|m) echo "You selected to modify an entry in the phone book"
			echo "Enter the name, OR the phone number of the entry you want to MODIFY"
			read entrytomodify
			modifyentry $entrytomodify $userfile
			;;
		I|i) echo "You selected to print an entry from the phone book"
			echo "Enter the name, OR the phone muber of the entry to print"
			read entrytoprint
			findentry $entrytoprint $userfile
			;;
		P|p) echo "You selected to print all records in the phone book"
			echo "The records will be printed in accending order by the last name"
			awk '{print($2,"\t",$1,"\t",$3)}' $userfile | sort -f -s | column -t
			;;
		X|x) exit ;;
		  *) echo "Wrong selection. This option does not exit." ;;
	esac
	echo "Press [RETURN] for menu"
	read key
done
exit 0
