#!/bin/bash
# データセット・イベント単位の再集計：us-east-1 14 並列 + ap-southeast-2 6 並列（後ろから）。再実行すると済みファイルは飛ばす
cd "$(dirname "$0")/.."
for k in $(seq 0 13); do nohup Rscript scripts/events_worker.R $k 14 > logs/events_us_$k.log 2>&1 & done
for k in $(seq 0 5); do GBIF_REGION=ap-southeast-2 REVERSE=1 nohup Rscript scripts/events_worker.R $k 6 > logs/events_syd_$k.log 2>&1 & done
wait
echo "$(date) events done" >> logs/events_launch.log
