#!/bin/bash
# GBIF スナップショット集計を K 並列で実行（再実行すると済みファイルは飛ばす）
cd "$(dirname "$0")/.."
K=${1:-16}
mkdir -p logs
for k in $(seq 0 $((K-1))); do
  nohup Rscript scripts/phase2_worker.R $k $K > logs/phase2_worker_$k.log 2>&1 &
done
wait
echo "$(date) all workers done" >> logs/phase2_launch.log
