# Phase 7b：PNAS に向けた補強（2026-11-03、すべて探索的）

Doi の指示：(1) 脊椎動物の独立センサス、(2) 占有ベースの比較、(3) 無脊椎動物自身の φ、(4) 先行研究のチェック。

1. **脊椎動物**（`docs/provenance_parts/vert_census.md`、`sim/explore_vi_vertebrates.R`）：
   * 独立な全球 N があったのは哺乳類 52 種：海生 45 種（Greenspoon 2025 の調査・漁獲モデル、2 種は IUCN）、サイ 4 種、サバンナゾウ（Great Elephant Census、18 か国のみで部分的）。
   * これらは Tier B の外挿線より log10 で +3.8 [1.7, 5.9]、報告ベースの陸生哺乳類 389 種は +4.9 [3.2, 6.7]。
   * **鳥類と哺乳類の上乗せは、循環のないセンサスでも残った。**
   * 海鳥は資料にアクセスできず（Brooke 2004 の付録）。魚は RAM Legacy に資源単位の N しかなく（30 種、うち 205 資源はサケ）、平均体重もないので見送った。
2. **占有ベース**（`sim/explore_vii_occupancy.R`、`explore_viii_compare.R`、補足図）：
   * 種 × 年の占有 1° セル数は、記録数より φ が 2〜10 倍大きく、年変動が小さい。
   * 記録の多い種では検出が 10〜18 年早まる。年 1 件未満の種は、どちらでも 100 年以内に検出できない。
   * 主張「記録の少ない小型種の減少は検出できない」は維持される。
3. **グループ自身の φ**（`sim/explore_v_group_phi.R`）：
   * 検出できない割合は 2〜7 ポイント上がった（線虫 96%、アリ 76% など）。
   * 検出の下限は 36〜61 年。
   * 主図 2b を差し替えた。
4. **先行研究**（`docs/literature_positioning.md`）：
   * 同じことをしている論文は見つからなかった。
   * 部分的に重なるのは Callaghan 2023 NEE（H5）、Isaac 2014 と Kamp 2016（偽の傾向と検出力）、Currie 2022（LPI の体サイズ、カナダの魚）。
   * 想定される反論：Outhwaite 2020（占有モデルでの英国の無脊椎動物の傾向）、指数 3/4 との区別、記載年は体サイズより分布域に左右される（Collen 2004）。

更新したもの：`figs/main_1_scaling.*`、`figs/main_2_detection.*`、`figs/supp_occupancy_vs_records.*`、`reports/summary.md`、`reports/results_draft_en.md`。

## 決定（2026-11-03、Doi）
* LPI の解析は LPD 2016 公開版（rlpi リポジトリ）で確定とする（「10 年前なら許容範囲」）。2026.1 は使わない。
* SquamBase（爬虫類の体重）と海鳥の資料は必須にしない。限界として記載する。
