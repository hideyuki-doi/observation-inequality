# Phase 1 センサス調査：各担当の出力形式

各担当は以下の2ファイルを書く（<id> は担当名）:

1. `docs/provenance_parts/<id>.csv` — 1行 = 1分類群グループ × 1出典。列（この順、UTF-8、カンマ区切り、引用符で囲む）:
   group, tier, realm, N_est, N_lo, N_hi, N_interval_type, B_est, B_lo, B_hi, B_unit, B_interval_type,
   n_described_species, n_described_source, method_class, method_evidence, citation, doi,
   location_in_source, retrieved_file, verified, notes
   - N は個体数（そのままの数値、例 4.4e20）。
   - B は出典の単位のまま（Gt C、Mt 湿重量 など）。B_unit に明記。換算はしない（換算は統合時に行い、換算係数も出典付きで記録）。
   - *_interval_type: CI95 / CI90 / range / SD / fold_uncertainty / none / 未確認
   - method_class: independent / occurrence-derived / allometry-derived / mixed / unclear
   - verified: yes（原典の本文・表・データで数値を確認した）/ 未確認（二次情報のみ・アクセス不可）
   - 確認できない値は空欄にし、notes に理由を書く。推測で埋めない。
2. `docs/provenance_parts/<id>.md` — 各数値について：原典の該当箇所の逐語引用（英語原文のまま）、URL、推定方法の要約、method_class の判定理由、迷った点。
