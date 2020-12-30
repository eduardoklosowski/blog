#!/bin/bash

EXECUCOES=100

(
echo 'codigo,tempo,memoria'
for e in $(seq 1 $EXECUCOES); do
  for i in $(seq 1 4); do
    /usr/bin/time -f "$i,%e,%M" php "codigo$i.php"
  done
done
) |& tee dados.csv
gzip -9 dados.csv
