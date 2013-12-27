Author: Corey Ramirez-Gomez

Website: www.coreyramirezgomez.com

Purpose: Monitor Brother Model SNMP enabled printers.

Current Verison: 
2.0 - Consumables Check

Planned Versions: 
2.5 - Paper checking?
3.0 - Messages

Version Details:
1.0 - initial commit with consumable monitoring.
2.0 - Changed the way consumables were "calculated" and delivered to the zabbix console using items instead of triggers. Added HTTP Checks, JetDirect, and Print Spooler Check:

Description:

Import this template into your zabbix configuration via the import button under configuration>templates.

The template does the work for discovering the consumables in the printer has and will display them accordingly. 

I loosely based this off the following bash script for Nagios Monitoring: http://exchange.nagios.org/directory/Plugins/Hardware/Printers/check_snmp_printer/details

The script should also be included in the git repo, but I cannot gauruntee it is the most up to date.
