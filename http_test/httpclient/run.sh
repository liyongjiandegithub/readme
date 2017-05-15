# !/bin/bash
gcc httpclient.c -o httpclient
#echo "请输入URL: "
#read path
read -p "Please Input URL: " path
./httpclient $path
