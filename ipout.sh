chip=7;
if [ $# -ge 1 ];  then
chip=$1;
fi

MonitorChassisIP=127.0.0.1;
BasePort=7300;

let "DataPortStart=$BasePort+0"
let "DataPortEnd=$DataPortStart+11"
let "LogPortStart=$BasePort+100"
let "LogPortEnd=$LogPortStart+13"
let "CommandPortStart=$BasePort+200"
let "CommandPortEnd=$CommandPortStart+13"
let "StatusPortStart=$BasePort+300"
let "StatusPortEnd=$StatusPortStart+13"

echo "-------------------------------"
echo "--CmdPort $CommandPortStart:$CommandPortEnd --StatusPort $StatusPortStart:$StatusPortEnd --LogPort $MonitorChassisIP:$LogPortStart:$LogPortEnd --DataPort $DataPortStart:$DataPortEnd"
echo "-------------------------------"

cd /usr/local/dx7753/StatMux2/

./pcietsout --Chip $chip --CmdPort 4400 --StatPort 19001 --LogPort 19002 --OutputMode UDP:172.18.16.109:12380

