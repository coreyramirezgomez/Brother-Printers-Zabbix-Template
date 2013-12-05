#!/bin/sh

###############################################################################
# +-------------------------------------------------------------------------+
# | Copyright (C) 2007 S&L Netzwerktechnik                                  |
# |                                                                         |
# | This program is free software; you can redistribute it and/or           |
# | modify it under the terms of the GNU General Public License             |
# | as published by the Free Software Foundation; either version 2          |
# | of the License, or (at your option) any later version.                  |
# |                                                                         |
# | This program is distributed in the hope that it will be useful,         |
# | but WITHOUT ANY WARRANTY; without even the implied warranty of          |
# | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           |
# | GNU General Public License for more details.                            |
# +-------------------------------------------------------------------------+
# |Monitoring Solution: The Complete Network Monitoring Solution :)         |
# +-------------------------------------------------------------------------+
# | This code is designed, written, and maintained by the Serge Mueller/ S&L|
# +-------------------------------------------------------------------------+
# | http://www.monitoring-solution.de/                                      |
# +-------------------------------------------------------------------------+
###############################################################################
#
#  check_snmp_printer - printer/consumables monitoring plugin for Nagios
#  Version: 0.1.0
#
###############################################################################
#
#  CHANGE LOG
#
#  2007-05-23 - Script creation
#  2007-06-06 - Added CONSUM ALL functionality
#
###############################################################################
#
#  COMMENTS
#  The Papertray stuff may need some attention...
#  Most printers' output sucks there
#
#
###############################################################################
#
#  DEPENDS On
#  snmpwalk - if needet change variable below
#  snmpget - see above
#
###############################################################################



HOSTIP=$1
COMMUNITY=$2


SNMPGET="/usr/bin/snmpget"
SNMPWALK="/usr/bin/snmpwalk"



function fmodel(){

MODEL=`$SNMPGET -v 1 -c $COMMUNITY $HOSTIP host.hrDevice.hrDeviceTable.hrDeviceEntry.hrDeviceDescr.1 2>/dev/null|cut -d " " -f4-`
echo $MODEL
exit 0
}
function fmessages(){
MESSAGES=`$SNMPWALK -v1 -c $COMMUNITY $HOSTIP 1.3.6.1.2.1.43.18.1.1.8|cut -d " " -f4- |tr -d "\""|tr -d "\n"`
echo $MESSAGES
exit 0
}



function fpagecount(){

PC=`$SNMPGET -v 1 -c $COMMUNITY $HOSTIP  1.3.6.1.2.1.43.10.2.1.4.1.1 2>/dev/null|cut -d " " -f4-`
echo "OK Pagecount is $PC|Pages=$PC;;;"
exit 0
}



function fconsumables(){

##testfrage

if [ "$1" = "TEST" ]
then
echo -e "Consumables you may Monitor:"
$SNMPWALK -v1 -c $COMMUNITY $HOSTIP  1.3.6.1.2.1.43.11.1.1.6.1 2>/dev/null |cut -d " " -f4-   
#echo -e $OUTPUT
exit 0
else


###massenabfrage

if [ "$1" = "ALL" ]
then

EXITCODE=0
EXITSTRING=''
PERFDAT=''
for ID in `$SNMPWALK -v1 -c $COMMUNITY $HOSTIP  1.3.6.1.2.1.43.11.1.1.6.1 2>/dev/null |egrep -oe '[[:digit:]]+\ ='|cut -d " " -f1`
do
NAME=`$SNMPGET -v1 -c $COMMUNITY $HOSTIP  1.3.6.1.2.1.43.11.1.1.6.1.$ID 2>/dev/null |cut -d " " -f4- |tr -d "\""`
if [ -z "$NAME" ]
        then
        echo "Error OID not found,maybe your Printer does not support checking this device, call me with Option CONSUM TEST or see help"
        exit 3
fi

STATUS=`$SNMPGET -v1 -c $COMMUNITY $HOSTIP  1.3.6.1.2.1.43.11.1.1.9.1.$ID 2>/dev/null |cut -d " " -f4- |tr -d "\""`
FULL=`$SNMPGET -v1 -c $COMMUNITY $HOSTIP  1.3.6.1.2.1.43.11.1.1.8.1.$ID 2>/dev/null |cut -d " " -f4- |tr -d "\""`


####debug
#echo found $ID with name $NAME , full state: $FULL , actual state: $STATUS

if [ "$FULL" -gt 0 ] && [ "$STATUS" -gt 0 ]
        then
        let "STATUS= $STATUS * 100 / $FULL"
        if [ "$STATUS" -gt "30" ]
                then
                EXITSTRING="$EXITSTRING OK,$NAME is at $STATUS%"
                PERFDAT="$PERFDAT $NAME=$STATUS;;$FULL;"
                else
                if [ "$STATUS" -lt "30" ] && [ "$STATUS" -gt "10" ]
                        then
                        EXITSTRING="$EXITSTRING, WARNING,$NAME is at $STATUS%"
			PERFDAT="$PERFDAT $NAME=$STATUS;;$FULL;"
	                if [ "$EXITCODE" -lt 1 ]
			then
			EXITCODE=1
			fi
				
                        else
                        if [ "$STATUS" -lt "10" ]
                                then
                                EXITSTRING="$EXITSTRING CRITICAL,$NAME is at $STATUS%"
				PERFDAT="$PERFDAT $NAME=$STATUS;;$FULL;"
        	                EXITCODE=2
                        fi
                fi
        fi

else
if [ "$STATUS" = "-3" ]
        then
	 EXITSTRING="$EXITSTRING OK,$NAME is FULL"
        else
        if [ "$STATUS" = "-2" ]
                then
		 EXITSTRING="$EXITSTRING WARNING,$NAME is at WARNING Level"
	                if [ "$EXITCODE" -lt 1 ]
        	        then
                        EXITCODE=1
                        fi
		else
                if [ "$STATUS" = "0" ]
                        then
			EXITSTRING="$EXITSTRING CRITICAL,$NAME is at CRITICAL Level"
			EXITCODE=2
                fi
        fi
fi

fi

done
echo "$EXITSTRING|$PERFDAT"
exit $EXITCODE





###einzelne abfrage
else
ID=`$SNMPWALK -v1 -c $COMMUNITY $HOSTIP  1.3.6.1.2.1.43.11.1.1.6.1 2>/dev/null |egrep -i -e "$1"|cut -d "=" -f1|cut -d "." -f8`
fi
fi
NAME=`$SNMPGET -v1 -c $COMMUNITY $HOSTIP  1.3.6.1.2.1.43.11.1.1.6.1.$ID 2>/dev/null |cut -d " " -f4- |tr -d "\""`
if [ -z "$NAME" ]
	then 
	echo "Error OID not found,maybe your Printer does not support checking this device, call me with Option CONSUM TEST or see help"
	exit 3 
fi

STATUS=`$SNMPGET -v1 -c $COMMUNITY $HOSTIP  1.3.6.1.2.1.43.11.1.1.9.1.$ID 2>/dev/null |cut -d " " -f4- |tr -d "\""`
FULL=`$SNMPGET -v1 -c $COMMUNITY $HOSTIP  1.3.6.1.2.1.43.11.1.1.8.1.$ID 2>/dev/null |cut -d " " -f4- |tr -d "\""`
if [ "$FULL" -gt 0 ] && [ "$STATUS" -gt 0 ]
	then 
	let "STATUS= $STATUS * 100 / $FULL"
	if [ "$STATUS" -gt "30" ]
		then 
 		echo "OK,$NAME is at $STATUS%|$NAME=$STATUS;;$FULL;"
        	exit 0
		else 
		if [ "$STATUS" -lt "30" ] && [ "$STATUS" -gt "10" ]
			then
 			echo "WARNING,$NAME is at $STATUS%|$NAME=$STATUS;;$FULL;"
        		exit 1 
			else 
			if [ "$STATUS" -lt "10" ]
				then
				echo "CRITICAL,$NAME is at $STATUS%|$NAME=$STATUS;;$FULL;"
        			exit 2
			fi
		fi
	fi

else
if [ "$STATUS" = "-3" ]
	then
	echo "$NAME is OK"
	exit 0
	else
	if [ "$STATUS" = "-2" ]
		then 
		echo "$NAME is at warning level"
		exit 1
		else
		if [ "$STATUS" = "0" ]
                	then 
			echo "$NAME is at critical level"
			exit 2
		fi
	fi
fi

fi
}




function fpaper1(){
PAPERSTATUS1=`$SNMPGET -v1 -c $COMMUNITY $HOSTIP  1.3.6.1.2.1.43.8.2.1.10.1.1|cut -d " " -f4- |tr -d "\""`
if [ "$PAPERSTATUS1" = "-3" ]
        then
        echo "TRAY1 is OK"
	exit 0
        else
        if [ "$PAPERSTATUS1" = "-2" ]
                then
                echo "TRAY1 is at warning level"
		exit 1
                else
                if [ "$PAPERSTATUS1" = "0" ]
                        then
                        echo "TRAY1 is at critical level"
			exit 2
                fi
        fi
fi
}


function fpaper2(){
PAPERSTATUS2=`$SNMPGET -v1 -c $COMMUNITY $HOSTIP   1.3.6.1.2.1.43.8.2.1.10.1.2|cut -d " " -f4- |tr -d "\""`
if [ "$PAPERSTATUS2" = "-3" ]
        then
        echo "TRAY2 is OK"
	exit 0
        else
        if [ "$PAPERSTATUS2" = "-2" ]
                then
                echo "TRAY2 is at warning level"
		exit 1
                else
                if [ "$PAPERSTATUS2" = "0" ]
                        then
                        echo "TRAY2 is at critical level"
			exit 2
                fi
        fi
fi
}


function fpaper3(){
PAPERSTATUS3=`$SNMPGET  -v1 -c $COMMUNITY $HOSTIP  1.3.6.1.2.1.43.8.2.1.10.1.3|cut -d " " -f4- |tr -d "\""`
if [ "$PAPERSTATUS3" = "-3" ]
        then
        echo "TRAY3 is OK"
	exit 0
        else
        if [ "$PAPERSTATUS3" = "-2" ]
                then
                echo "TRAY3 is at warning level"
		exit 1
                else
                if [ "$PAPERSTATUS3" = "0" ]
                        then
                        exit "TRAY3 is at critical level"
			exit 2
                fi
        fi
fi
}
function ferror(){
echo usage is:
echo "$0 <HOSTIP> <COMMUNITY> <CHECK>"
echo "     where CHECK can be:"
echo -e "        	        MESSAGES"
echo -e "         	        MODEL"
echo -e "         	        CONSUM TEST"
echo -e "         	        CONSUM ALL"

echo -e "	                CONSUM <String>" 
echo -e "	                PAPER1"
echo -e "	                PAPER2"
echo -e "	                PAPER3"
echo -e "	                PAGECOUNT"
echo -e "CONSUM TEST, will give you the exact Names of installed Consumables like:"
echo -e "\"Black Toner Cartridge HP C4191A\""
echo -e "For monitoring this consumable you'll call me like this:"
echo -e "$0 <HOSTIP> <COMMUNITY> CONSUM black"
echo -e "The string just needs to be unique"
echo -e "CONSUM ALL will give you all the Stuff at once..."

}

if [ "$#" -lt 3 ]
	then 
	ferror
	exit 3
fi		

if [ "$3" = "MESSAGES" ]
	then 
	fmessages
else
if [ "$3" = "MODEL" ]
	then
	fmodel
else
if [ "$3" = "CONSUM" ]
	then
	fconsumables $4	
else 
if [ "$3" = "PAPER1" ]
	then
	fpaper1
else
if [ "$3" = "PAPER2" ]
        then
        fpaper2
else
if [ "$3" = "PAPER3" ]
        then
        fpaper3
else
if [ "$3" = "PAGECOUNT" ]
        then
        fpagecount
else
if [ "$3" = "TEST" ]
        then
        fconsumables $3
else
	ferror
	exit 3
fi
fi
fi
fi
fi
fi
fi
fi
echo UNKNOWN something went wrong whilst checking the stats
exit 3
