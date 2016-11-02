#! /bin/bash
#
for i in `seq 1 10`;do
  if id user$i &> /dev/null;then
   echo "user$i exists."
  else
   useradd user$i
   echo user$i | passwd --stdin user$i &>/dev/null
   echo "user$i add finished."
  fi
done 
