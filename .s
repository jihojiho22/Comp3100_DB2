#! /bin/sh

# usage: A3_donut_loop.sh  number_of_runs_integer
# so from the shell prompt:  $ ./A3_donut_loop.sh 10 
# will run the producer program and the consumer
# programs (5 of them) 10 times and report how many
# of the 10 runs ended in deadlock

if [ -z $1 ]
then
echo " "
echo " "
echo "USAGE: A1_linux_donut_loop.sh  number_of_runs_integer"
echo "Try the command again"
echo " "
exit 1
fi

echo " "
echo " "
echo " "
echo "The configuration is for $1 LOOPS"
echo " "

local1=$1
lpcnt=1
count=0
while test $local1 -ne 0
do
echo "___________________________________________________________"
echo " "
echo "Working on LOOP $lpcnt"
echo " "
./producer & 
sleep 1 
./consumer 1 > c1 & ./consumer 2 > c2 & ./consumer 3 > c3 & ./consumer 4 > c4 & ./consumer 5 > c5 &
sleep 10
pid=`ps | grep -v 'grep' | grep 'producer' | awk '{print $1}'`
if ps | grep -v 'grep' | grep -q 'consumer'
then
echo " "
echo "DEADLOCK DETECTED ON LOOP $lpcnt"
echo " "
count=`expr $count + 1`
else
echo "LOOP $lpcnt COMPLETED SUCCESSFULLY"
echo " "
fi
echo ">>>>>>>> NOW KILLING THE PRODUCER PROCESS PID: $pid"
kill $pid
local1=`expr $local1 - 1`
lpcnt=`expr $lpcnt + 1`
sleep 1
done
echo "___________________________________________________________"
echo " "
echo $1 loops and $count deadlocks
echo " "
echo " "


