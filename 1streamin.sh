chip=7;

MonitorChassisIP=127.0.0.1;
BasePort=7300;

let "DataPortStart=$BasePort+0+$chip*100"
let "DataPortEnd=$DataPortStart+11"
let "LogPortStart=$BasePort+15+$chip*100"
let "LogPortEnd=$LogPortStart+13"
let "CommandPortStart=$BasePort+30+$chip*100"
let "CommandPortEnd=$CommandPortStart+13"
let "StatusPortStart=$BasePort+45+$chip*100"
let "StatusPortEnd=$StatusPortStart+13"


let "OutLogPortStart=$BasePort+60+$chip*100"
let "OutCommandPortStart=$BasePort+70+$chip*100"
let "OutStatusPortStart=$BasePort+80+$chip*100"

cd /usr/local/dx7753/StatMux2/
./TSOverPCIEIn --Chip $chip --CmdPort $CommandPortStart:$CommandPortEnd --StatusPort $StatusPortStart:$StatusPortEnd --LogPort $MonitorChassisIP:$LogPortStart:$LogPortEnd --DataPort $DataPortStart:$DataPortEnd \
    --CH 0 --InputMode File:/local/home/localadm/bshen/8ch_MPEG2_720x576i50_Main_Main_4x3_diffContent_10min.ts --PCRPid 1000 --RemapPID 1000:1000 \
    --CH 6 --InputMode File:/local/home/localadm/bshen/dual_720p5994_MPEG2_High_High_10audio_48kHz_MP1L2_AC3_EAC3_AAC.ts --PCRPid 1006 --RemapPID 1006:1006
