#!/bin/bash
source prepare_re2_chrono.sh
source prepare_re2_test.sh
#benchmarks=(protomata snort brill clamAV)
benchmarks=(brill clamAV snort)
for i in ${benchmarks[@]}
do
	echo "[INFO] Executing benchmark $i"
	python3 measure_rand.py -re2chrono 30 -strfile="$i.input" -regfile="$i.regex" -skipException -format=pcre -benchmark="$i"
	python3 measure_rand.py -re2chrono 30 -strfile="$i.input" -regfile="$i.regex" -skipException -format=pythonre -benchmark="$i"
done
