#!/bin/bash

SUM_TOT=0
for id in core sdram_c sdram_i sdram_p ; do \
    echo -e " $id:\t$(vcgencmd measure_volts $id)" ; \
    IFS='=' read -ra MESURE <<< "$(vcgencmd measure_volts $id)"
    MESURE="${MESURE[1]}"
    COUNT=$((${#MESURE} - 1))
    SUM_TOT=$(bc -l <<<"${SUM_TOT}+${MESURE:0:$COUNT}")
    #SUM_TOT=$(($SUM_TOT + ${MESURE:0:$COUNT - 1}))
done
echo -e " total:\t${SUM_TOT}V"

exit 0