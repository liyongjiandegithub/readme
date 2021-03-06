# CRC Code : 244
# #########################################################
# Automatically Generated By ScriptGenerator (Version 1.5.5.2)
# Generated On 2015-12-02 13:23:09
# Target Project :  R11X
# Test Plan Name :  QA-DynamicMS-TestPlan.xls
# Entry sheet    :  R11X_DynamicMS
# #########################################################

#>AdditionalInfo -CaseID R11X_DynamicMS_0001 -instance 0
#>AdditionalInfo -SG_OutputDuration 60 -instance 0
#>AdditionalInfo -SG_TestResultFileName Results_R11X_DynamicMS.csv -instance 0
#>AdditionalInfo -AudNum 2 -instance 0
#>AdditionalInfo -InputStreamName H264_1ch_720x576i50_Main_30_8Audio_17SP_10min.ts -instance 0
#>AdditionalInfo -InputVideoType 0 -instance 0
#>AdditionalInfo -InputResolution 720x576i25 -instance 0

# #########################################################

chip=7;
if [ $# -ge 1 ];  then
chip=$1;
fi

AudioConfigFilePath=/usr/local/dx7753/bin/AudioAllocConfig.Chip$chip.txt
echo '#
#--------------------------------------------------
#                       README
#  This configure file is used to apply the audio codec resources.
#  There are 32 codec-query arrays with the same content. If user
#  want to configure 4 audio CODECs (2 for decoder, 2 for encoder),
#  user should configure the audio codec query information array
#  from index 0 to index 3 in order.
#  User need to configure these 5 items:
#    - configure codec Num : The total number of audio decoder and
#                            encoder you want to configure; User MUST
#                            set this option.
#    - instanceID:   the ID of audio codec , the value range is 0~15
#    - audioType:    the codec type such as AAC, AC3, MPEG...
#    - numCh:        the audio channel number of this codec,
#    - isDec:        the codec is decoder or encoder. Decoder is 1
#                    encoder is 0
#    - passthru:     the output mode is passthrough or not.
#                    Passthrough mode is 1 and non-passthrough is 0
#--------------------------------------------------
configure codec Num : 4
#--------------------------------------------------
The audio codec query information for index : 0
instanceID : 0
audioType  : 20
numCh      : 2
isDec      : 1
passthru   : 0
#--------------------------------------------------
The audio codec query information for index : 1
instanceID : 1
audioType  : 20
numCh      : 2
isDec      : 1
passthru   : 0
#--------------------------------------------------
The audio codec query information for index : 2
instanceID : 0
audioType  : 20
numCh      : 2
isDec      : 0
passthru   : 0
#--------------------------------------------------
The audio codec query information for index : 3
instanceID : 1
audioType  : 20
numCh      : 2
isDec      : 0
passthru   : 0
#--------------------------------------------------
' > $AudioConfigFilePath

cd /usr/local/dx7753/bin
./multiInit.pl -product 11CX -startChip $chip;
#./multiRun.pl -startChip $chip;
#/root/bshen/code/503/cware/x86/startup/r12c -c $chip &
#/root/yli/git_1663/cware-repo/x86/startup/r12c -c $chip &
/lsi/home/yli/r12cpu/cware-repo/x86/startup/r12c_unsec -c $chip &

./xcode.queryAudioAlloc.pl -file $AudioConfigFilePath  -startChip $chip;
./xcode.configSystem.pl -u32SystemConfigA 25 -u32SystemConfigB 19 -startChip $chip;

#---- Config Demux configuration ----#
./xcode.configDemux.pl -source 2 -startChip $chip;

#---- Config Outputmux configuration ----#


#---- Config Demux stream information of Input Channels ----#
./xcode.configDemuxStreamInfo.pl -pid 1000 -encoding 1 -instance 0  -startChip $chip;
./xcode.configInputChannel.pl -contipcr 0 -instance 0  -startChip $chip;
./xcode.configDemuxPSI.pl -pcr 1000 -instance 0  -startChip $chip;

./xcode.configDemuxStreamInfo.pl -pid 1006 -encoding 1 -instance 102  -startChip $chip;
./xcode.configInputChannel.pl -contipcr 0 -instance 6  -startChip $chip;
./xcode.configDemuxPSI.pl -pcr 1006 -instance 6  -startChip $chip;

./xcode.configVpp.pl -width 720 -height 576 -frmrate 3 -vidformat 1 -bypass 0 -hscal 13 -instance 8 -startChip $chip;
./xcode.configVpp.pl -bypass 0 -followinput 1 -hscal 12 -instance 9 -startChip $chip;


#---- Config Video information of Output Channels ----#
#-----------------------HALF A------------------------#
# R4  CHL 0
./xcode.configGenericVideoEnc.pl -vidPid 1000 -encType 0 -u32CodingMode 1 -u32BitRate 2000000 -instance 0 -startChip $chip;
./xcode.configTSPrg.pl -u32PCRPID 1000 -instance 0 -startChip $chip;
./xcode.configVpp.pl -width 720 -height 576 -frmrate 3 -vidformat 1 -instance 0 -startChip $chip;
./xcode.configOutputChannel.pl -srcChn 0 -ETEDelay 4500 -instance 0 -startChip $chip;

# R4  CHL 1
./xcode.configGenericVideoEnc.pl -vidPid 1001 -encType 0 -u32CodingMode 1 -u32BitRate 2000000 -instance 1 -startChip $chip;
./xcode.configTSPrg.pl -u32PCRPID 1001 -instance 1 -startChip $chip;
./xcode.configVpp.pl -width 720 -height 576 -frmrate 3 -vidformat 1 -instance 1 -startChip $chip;
./xcode.configOutputChannel.pl -srcChn 0 -ETEDelay 4500 -instance 1 -startChip $chip;

# R4  CHL 8
./xcode.configGenericVideoEnc.pl -vidPid 1008 -encType 0 -u32CodingMode 1 -u32BitRate 420000 -instance 8 -startChip $chip;
./xcode.configTSPrg.pl -u32PCRPID 1008 -instance 8 -startChip $chip;
./xcode.configVSC.pl -width 720 -height 576 -frmrate 3 -vidformat 1 -instance 0 -startChip $chip;
./xcode.configOutputChannel.pl -srcChn 0 -ETEDelay 4500 -instance 8 -startChip $chip;

# R4  CHL 9
./xcode.configGenericVideoEnc.pl -vidPid 1009 -encType 0 -u32CodingMode 1 -u32BitRate 420000 -instance 9 -startChip $chip;
./xcode.configTSPrg.pl -u32PCRPID 1009 -instance 9 -startChip $chip;
./xcode.configVSC.pl -width 720 -height 576 -frmrate 3 -vidformat 1 -instance 1 -startChip $chip;
./xcode.configOutputChannel.pl -srcChn 0 -ETEDelay 4500 -instance 9 -startChip $chip;


#-----------------------HALF B------------------------#
./xcode.configGenericVideoEnc.pl -vidPid 1004 -encType 0 -u32CodingMode 1 -u32BitRate 5000000 -instance 4 -startChip $chip;
./xcode.configTSPrg.pl -u32PCRPID 1004 -instance 4 -startChip $chip;
./xcode.configVpp.pl -width 1280 -height 720 -frmrate 4 -vidformat 1 -instance 4 -startChip $chip;
./xcode.configOutputChannel.pl -srcChn 6 -ETEDelay 4500 -instance 4 -startChip $chip;

./xcode.configGenericVideoEnc.pl -vidPid 1005 -encType 0 -u32CodingMode 1 -u32BitRate 2000000 -instance 5 -startChip $chip;
./xcode.configTSPrg.pl -u32PCRPID 1005 -instance 5 -startChip $chip;
./xcode.configVpp.pl -width 640 -height 480 -frmrate 4 -vidformat 1 -instance 5 -startChip $chip;
./xcode.configOutputChannel.pl -srcChn 6 -ETEDelay 4500 -instance 5 -startChip $chip;

./xcode.configGenericVideoEnc.pl -vidPid 1013 -encType 0 -u32CodingMode 1 -u32BitRate 420000 -instance 13 -startChip $chip;
./xcode.configTSPrg.pl -u32PCRPID 1013 -instance 13 -startChip $chip;
./xcode.configVSC.pl -width 432 -height 240 -frmrate 4 -vidformat 1 -instance 5 -startChip $chip;
./xcode.configOutputChannel.pl -srcChn 6 -ETEDelay 4500 -instance 13 -startChip $chip;


#---- Config TS MUX ----#
./xcode.configTSMux.pl -u32BitRate 14000000 -startChip $chip;
./xcode.configOutputMux.pl -sink 2 -startChip $chip;

#---- Init the flow ----#
./xcode.init.pl -startChip $chip;
#---- Start the flow ----#
./xcode.start.pl -startChip $chip;

./xcode.initDecode.pl -instance 0 -startChip $chip;
#./xcode.initDecode.pl -instance 6 -startChip $chip;

./xcode.initEncode.pl -instance 0 -startChip $chip;
#./xcode.initEncode.pl -instance 1 -startChip $chip;
#./xcode.initEncode.pl -instance 8 -startChip $chip;
#./xcode.initEncode.pl -instance 9 -startChip $chip;
#./xcode.initEncode.pl -instance 4 -startChip $chip;
#./xcode.initEncode.pl -instance 5 -startChip $chip;
#./xcode.initEncode.pl -instance 13 -startChip $chip;

./xcode.startEncode.pl -instance 0 -startChip $chip;
#./xcode.startEncode.pl -instance 1 -startChip $chip;
#./xcode.startEncode.pl -instance 8 -startChip $chip;
#./xcode.startEncode.pl -instance 9 -startChip $chip;
#./xcode.startEncode.pl -instance 4 -startChip $chip;
#./xcode.startEncode.pl -instance 5 -startChip $chip;
#./xcode.startEncode.pl -instance 13 -startChip $chip;

./xcode.startDecode.pl -instance 0 -startChip $chip;
#./xcode.startDecode.pl -instance 6 -startChip $chip;

