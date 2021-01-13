#!/bin/bash

#Number of relay in smart plug
PLUGS_COUNT=3
# Do not change this
SESSIONID="01234567890123456789012345678901"

usage() {
   echo "Usage: $0 [arguments]"
   echo -e "\tArgument list:"
   echo -e "\t-u: \t mFi Username"
   echo -e "\t-p: \t mFi Password" 
   echo -e "\t-i: \t mFi IP Address" 
   echo -e "\t-c: \t Command to execute  [ on | off | restart | restart-all | emeter ]"
   echo -e "\t\t on \t\t-\t Turns on power on relay number provided with -r "
   echo -e "\t\t off \t\t-\t Turns off power on relay number provided with -r "
   echo -e "\t\t restart \t-\t Turns off power then on after 5 seconds on relay number provided with -r"
   echo -e "\t\t restart-all \t-\t Turns off power then on after 5 seconds on all relays"
   echo -e "\t\t emeter \t-\t Output data in json format"   
   echo -e "\t-r: \t Execute [ on | off | restart ] on which relay/port" 
   echo -e "\t-h: \t Display this help"    
   exit 1
}

while getopts ":u:p:i:c:r:h" option
do
   case $option in
	u) 				MPOWER_USERNAME=$OPTARG;;	
	p) 				MPOWER_PASSWORD=$OPTARG;;	
	i) 				MPOWER_IP=$OPTARG;;
    c) 				COMMAND=$OPTARG;;
    r) 				RELAY=$OPTARG;;	
    h) 				usage;;	
    \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
    :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
    *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
   esac
done

#Manual shift to the next flag.
shift $(($OPTIND - 1))

mfi_login() {
    #Login the the device
    curl -s -X POST -d "username=$MPOWER_USERNAME&password=$MPOWER_PASSWORD" -b "AIROS_SESSIONID=$SESSIONID" "http://$MPOWER_IP/login.cgi"	
}

mfi_logout() {
    #Logout from the device
    curl -b "AIROS_SESSIONID=$SESSIONID" "http://$MPOWER_IP/logout.cgi"
}

if ping -c 1 $MPOWER_IP &> /dev/null; then
    [[ -z "$MPOWER_USERNAME" ]] && { echo "Username not provided, exiting..."; usage; }
    [[ -z "$MPOWER_PASSWORD" ]] && { echo "Password not provided, exiting..."; usage; }
    [[ -z "$MPOWER_IP" ]] && { echo "Ip Address not provided, exiting..."; usage; }
    [[ -z "$COMMAND" ]] && { echo "Command not provided, exiting..."; usage; }
    [[ X$COMMAND == "Xon" || X$COMMAND == "Xoff" || X$COMMAND == "Xrestart" ]] && [[ -z $RELAY ]] && { echo "Command '$COMMAND' needs -r parameter, exiting..."; usage; }
    

    
    
    if [ X"$COMMAND" == "Xemeter" ]; then
        mfi_login
        data=$(curl -b "AIROS_SESSIONID=$SESSIONID" -s "http://$MPOWER_IP/sensors" | python -m json.tool)
    	echo "$data"
		mfi_logout
    fi
    
    # Turn on
    [[ X"$COMMAND" == "Xon" ]] && { mfi_login; curl --silent -X PUT -d label=komp -b "AIROS_SESSIONID=$SESSIONID" "$MPOWER_IP/sensors/$RELAY" > /dev/null; mfi_logout; }
    #Turn off
    [[ X"$COMMAND" == "Xoff" ]] && { mfi_login; curl --silent -X PUT -d output=0 -b "AIROS_SESSIONID=$SESSIONID" "$MPOWER_IP/sensors/$RELAY" > /dev/null; mfi_logout; }
    
    #Restart port/relay
    if [ X"$COMMAND" == "Xrestart" ]; then
        mfi_login
        curl --silent -X PUT -d output=0 -b "AIROS_SESSIONID=$SESSIONID" "$MPOWER_IP/sensors/$RELAY" > /dev/null
    	sleep 3
    	curl --silent -X PUT -d output=1 -b "AIROS_SESSIONID=$SESSIONID" "$MPOWER_IP/sensors/$RELAY" > /dev/null
        mfi_logout
    fi
    
    #Restart all ports/relays
    if [ X"$COMMAND" == "Xrestart-all" ]; then
        for ((i = 1 ; i <= $PLUGS_COUNT ; i++)); do
            mfi_login
            curl --silent -X PUT -d output=0 -b "AIROS_SESSIONID=$SESSIONID" "$MPOWER_IP/sensors/$i" > /dev/null
    		sleep 3
    		curl --silent -X PUT -d output=1 -b "AIROS_SESSIONID=$SESSIONID" "$MPOWER_IP/sensors/$i" > /dev/null
            mfi_logout
        done
    fi
   
else
    echo "Could not contact mFi at $MPOWER_IP"
	exit 1
fi