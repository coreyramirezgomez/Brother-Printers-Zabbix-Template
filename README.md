*Author:* Corey Ramirez-Gomez

*Website:* www.coreyramirezgomez.com

*Purpose:* Monitor Brother Model SNMP enabled printers.

**Features:**
+ Check SNMP consumables like ink, toner and waste bin.
+ Check HTTP JetDirect Status

**Instructions:**
+ 1. Import the http_simple_check.xml
+ 2. Import the brother-printers-zabbix-template.xml
+ 3. Create a host and link the brother-printers-zabbix-template to it.
+ 4. Set the $COMMUNITY macro string to your SNMP Community if you have one, otherwise it will use the default.

**Description:** The template does the work for discovering the consumables in the printer has and will display them accordingly. I loosely based this off the following bash script for Nagios Monitoring: *http://exchange.nagios.org/directory/Plugins/Hardware/Printers/check_snmp_printer/details*
The script should also be included in the git repo, but I cannot gauruntee it is the most up to date.
