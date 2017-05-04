
ps -a | grep "pts/15" | awk '{print $1}' | xargs kill
