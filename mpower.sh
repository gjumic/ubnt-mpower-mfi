#!/bin/bash

SESSIONID="01234567890123456789012345678901"

    while [[ $# -gt 0 ]]; do
        opt="$1"
        shift;
        case "$opt" in
            "-u"|"--user"               ) MPOWER_USERNAME="$1"; shift;;
            "-p"|"--pass"               ) MPOWER_PASSWORD="$1"; shift;;
            "-i"|"--ip"                 ) MPOWER_IP="$1"; shift;;
			"-emeter"                   ) EMETER=TRUE;;
			"-on"                       ) TURN_ON="$1"; shift;;
			"-off"                      ) TURN_OFF="$1"; shift;;
			"-restart"                  ) RESTART="$1"; shift;;
            "-h"|"--help"               ) HELP=TRUE;;
            "\?"                        ) echo "Unknown option: -$OPTARG" >&2; exit;;
            ":"                         ) echo "Missing option argument for -$OPTARG" >&2; exit;;
            *                           ) echo -e "Unimplemented argument\n Try:\n\t mpower.sh --help" >&2; exit;;
        esac
    done

if [ X$HELP == "XTRUE" ]; then
    echo -e " Syntax:\n\tmpower.sh -u <username> -p <password> -i <ip address> -emeter|-on <port number>|-off <port number>|-restart <port number>"
	exit 0
fi

if [ -z "$MPOWER_USERNAME" ]; then
    echo "Username not provided, exiting..."
	exit 1
fi
if [ -z "$MPOWER_PASSWORD" ]; then
    echo "Password not provided, exiting..."
	exit 1
fi
if [ -z "$MPOWER_IP" ]; then
    echo "Ip Address not provided, exiting..."
	exit 1
fi

curl -s -X POST -d "username="$MPOWER_USERNAME"&password="$MPOWER_PASSWORD"" -b "AIROS_SESSIONID="$SESSIONID"" "http://"$MPOWER_IP"/login.cgi"

if [ X$EMETER == "XTRUE" ]; then
    
    data=$(curl -b "AIROS_SESSIONID=$SESSIONID" -s "http://$MPOWER_IP/sensors")
	echo $data
fi

[[ -z $TURN_ON ]] || curl --silent -X PUT -d output=1 -b "AIROS_SESSIONID="$SESSIONID $MPOWER_IP/sensors/$TURN_ON
[[ -z $TURN_OFF ]] || curl --silent -X PUT -d output=0 -b "AIROS_SESSIONID="$SESSIONID $MPOWER_IP/sensors/$TURN_OFF 
[[ -z $RESTART ]] || { curl --silent -X PUT -d output=0 -b "AIROS_SESSIONID="$SESSIONID $MPOWER_IP/sensors/$RESTART; sleep 5; curl --silent -X PUT -d output=1 -b "AIROS_SESSIONID="$SESSIONID $MPOWER_IP/sensors/$RESTART; }

