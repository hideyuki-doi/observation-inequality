#!/bin/bash
# 座標つき再集計：us-east-1 16 並列 + ap-southeast-2 8 並列（後ろから）。再実行すると済みファイルは飛ばす
cd "$(dirname "$0")/.."
for k in $(seq 0 15); do nohup Rscript scripts/cells_worker.R $k 16 > logs/cells_us_$k.log 2>&1 & done
for k in $(seq 0 7); do GBIF_REGION=ap-southeast-2 REVERSE=1 nohup Rscript scripts/cells_worker.R $k 8 > logs/cells_syd_$k.log 2>&1 & done
wait
echo "$(date) cells done" >> logs/cells_launch.log
