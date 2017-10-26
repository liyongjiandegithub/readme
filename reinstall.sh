#remove all old sudo rpm
sudo rpm -e R12COpenSource
sudo rpm -e DXAudioDLL
sudo rpm -e DX8753
sudo rpm -e DX9753
sudo rpm -e DX7753
sudo rpm -e DX7753-ENCODE
sudo rpm -e DX-ENCODE
sudo rpm -e DX-ENCODE-DP
sudo rpm -e DX-XCODE
sudo rpm -e DX-XCODE-DP
sudo rpm -e DXHostUtil
sudo rpm -e DXHostUtil-7753
sudo rpm -e D7HostAPI
sudo rpm -e DXHostAPI
sudo rpm -e DXHostAPI-7753
sudo rpm -e D7driver
sudo rpm -e DXKDriver
sudo rpm -e DXUDriver-7753
sudo rpm -e DXOpenSource
sudo rpm -e DXStatMux2Core
sudo rpm -e DXStatMux2
sudo rpm -e R12U-CPU
sudo rpm -e CPUHostUtil
sudo rpm -e CPUOpenSource
sudo rpm -e CPUStatMux2Core
sudo rpm -e CPUStatMux2
sudo rpm -e CPUHostAPI
sudo rpm -e CPUDriver


#install new sudo rpm
sudo rpm -i *DXOpenSource*.rpm
sudo rpm -i *D7driver*.rpm
sudo rpm -i *DXKDriver*.rpm
sudo rpm -i *DXUDriver*.rpm
sudo rpm -i *DXHostAPI*.rpm
sudo rpm -i *DXHostUtil*.rpm
sudo rpm -i *DXStatMux2Core*.rpm
sudo rpm -i *DXStatMux2-*.rpm
sudo rpm -i *DX-XCODE*.rpm
sudo rpm -i *R12COpenSource*.rpm
sudo rpm -i *CPUDriver*.rpm
sudo rpm -i *CPUHostAPI*.rpm
sudo rpm -i *CPUHostUtil*.rpm
sudo rpm -i *CPUOpenSource*.rpm
sudo rpm -i *CPUStatMux2Core*.rpm
sudo rpm -i *CPUStatMux2-*.rpm
sudo rpm -i *R12U-CPU*.rpm


