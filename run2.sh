#!/bin/bash

timestamp() {
  date +"%T"
}

# Tests configuration
TIMES=3

# TODO: complete parameters
BROKERS=(activemq)


TEST_CASES=("100 100000 100   100 1000" "100 100000 100   100 5000" "100 100000 100   100 10000" "100 100000 100   100 15000" "100 100000 100   100 20000" "100 100000 100   100 30000"
			"100 100000 1000  100 1000" "100 100000 1000  100 5000" "100 100000 1000  100 10000" "100 100000 1000  100 15000" "100 100000 1000  100 20000" "100 100000 1000  100 30000"
			"100 100000 5000  100 1000" "100 100000 5000  100 5000" "100 100000 5000  100 10000" "100 100000 5000  100 15000" "100 100000 5000  100 20000" "100 100000 5000  100 30000"
			"100 100000 10000 100 1000" "100 100000 10000 100 5000" "100 100000 10000 100 10000" "100 100000 10000 100 15000" "100 100000 10000 100 20000" "100 100000 10000 100 30000")



# Delete previous results
rm errors results.csv aux

timestamp

# Start trials
for (( j=0; j<=$(( ${#TEST_CASES[@]} -1 )); j++ ))
do
	for i in ${BROKERS[@]}
	do
		echo "Executing: $i ${TEST_CASES[j]}"

		for  (( k=0; k<=$(( $TIMES -1 )); k++ ))
		do

				if [ $i == "silboPS" ] ; then

					IFS=' ' read topics notifs subs msgSize freq <<< "${TEST_CASES[j]}"

					java -Xmx10G -Dnotifications=$notifs -Dsubscriptions=$subs -DnotificationFreq=$freq -DmsgSize=$msgSize -cp silboPS_benchmark.jar com.conwet.silbops.mapreduce.trials.StaticTopologyTest2 1>> errors 2>> aux &
					./jvmtop-0.8.0/monitor.sh

				elif [ $i == "rabbitmq" ] || [ $i == "activemq" ] ; then
					java -jar ./benchmark.jar $i  ${TEST_CASES[j]} 2>> errors 1>> aux &
					./jvmtop-0.8.0/monitor2.sh $i

				elif [ $i == "BE-Tree" ] ; then
					./BE-Tree/benchmark.sh -s $subs -e $notifs 2>> errors_betree 1>> salida_betree

				fi
		done
	done
done

cat -n aux | sort -k2 -k1n  | uniq -f1 | sort -nk1,1 | cut -f2- > results_1000rate_silboPS.csv
rm aux

timestamp