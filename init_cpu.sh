chip=7;
if [ $# -ge 1 ];  then
chip=$1;
fi
cd /usr/local/dx7753/src/utils/d7vir/
./d7vir_add -i $chip -f 1024 -n 1 -a 0
cd -

