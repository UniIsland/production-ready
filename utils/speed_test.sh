#!/bin/bash

[[ -f $1 ]] || {
  echo "Usage: `basename $0` server_list_file > result.tsv" >&2
  echo "  each line in server_list_file should have a name and an url to a file >10M, separated by tab" >&2
  exit 1
}

_run_speed_test() {
  HOST=`echo $2 | awk -F[/:] '{print $4}'`

  printf "%-10s\t" $1

  # printf "\tping %s\n" $HOST >&2
  ping -c 30 -q -n $HOST \
    | awk '/packets transmitted/ { loss_rate = $7 }; /round-trip/ { OFS="/"; print loss_rate, $4 }' \
    | sed -E  -e 's/\.[0-9]{3}//g' -e $'s#/#\t#g' \
    | tr '\n' '\t'

  # printf "\tcurl %s\n" $2 >&2

  {
    for i in {1..3}; do
      curl -sN --max-time 30 -w '%{speed_download}\n' -o /dev/null $2
    done
  } | awk '{ sum += $1; n++; print $1 } END { printf "%d\n", sum/n }' \
    | numfmt --to=iec-i \
    | tr '\n' '\t' \
    | sed -e $'s#\t#B/s\t#g'
}
export -f _run_speed_test

echo "Starting test, be patient ..." >&2

## tsv header
printf "Host      \tLoss\tMin\tAvg\tMax\tStdDev\tSpeed_01\tSpeed_02\tSpeed_03\tSpeed_avg\n"

cat $1 | xargs -n2 -I{} bash -c '_run_speed_test {} {}'

unset -f _run_speed_test
