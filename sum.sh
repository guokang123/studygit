#! /bin/bash
declare -i SUM=0
for (( i=1;i<=120;i++ ));do           
   let SUM=$(( $SUM + $i ))
done
echo $SUM
