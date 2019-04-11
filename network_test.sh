

while true;
do
  ping -c1 google.com
  if [ $? -eq 0 ]
  then 
    /root/scripts/test1.sh
    exit 0
  fi
done
