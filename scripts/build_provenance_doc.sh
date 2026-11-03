#!/bin/bash
# docs/provenance_parts/*.md を docs/data_provenance.md にまとめる（手で編集しない）
cd "$(dirname "$0")/.."
{
  echo "# データ出典記録（Phase 1 センサス）"
  echo
  echo "自動生成：scripts/build_provenance_doc.sh。各節の原本は docs/provenance_parts/<担当>.md、数値は同名 .csv → data/derived/census.csv。"
  echo "逐語引用は原典の英語のまま。B_lo/B_hi が fold uncertainty から計算されたものは notes に明記。"
  echo
  for f in milo soil_arthropods marine_other tierA harmonized richness lpd; do
    echo; echo "---"; echo
    sed 's/^# /## /' docs/provenance_parts/$f.md
  done
} > docs/data_provenance.md
