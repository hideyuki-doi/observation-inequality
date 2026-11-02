# Provenance notes — id `harmonized`（Phase 1 ゲート判断 3・5・7 と記載種数）

作成日 2026-11-03。対応ファイル：`harmonized.csv`（16行、22列＋`derived_formula`・`inputs`）、`docs/conversion_factors.csv`。
CSV は `scripts/harmonized/build_harmonized_csv.py` が生成する。数値はすべて、下の再計算出力・生データからそのまま写した。自分で計算した値は notes に「DERIVED」または「recomputed」と書き、式と入力の場所を `derived_formula`・`inputs` 列に入れた。

再現用スクリプト（プロジェクト内）：

| スクリプト | 役割 | 出力 |
|---|---|---|
| `scripts/harmonized/baron_subgroups.R` | Bar-On リポジトリの入力 xlsx から、部分群の B と1個体あたり質量をノートブック通りに再計算する | `data/derived/harmonized_baron_subgroups.txt` |
| `scripts/harmonized/run_rosenberg.py` | Rosenberg の Zenodo ノートブックを、必要なセルだけ無改変で実行する | `data/derived/harmonized_rosenberg_rerun_Nboot1e5_seed20261103.log` |
| `scripts/harmonized/col_counts.py` | ChecklistBank API に問い合わせ、生 JSON を保存する | `data/raw/checklistbank_col26.10/*.json`、要約は `data/derived/harmonized_col_species_counts.tsv` |

---

## 1. Bar-On 2018：B と N の範囲をそろえ直す（ゲート判断 3）

### 方法

* 対象は `data/raw/baron2018/biomass_distribution/`（commit 36cf0a80）。
* 各ノートブックの「N を計算するセル」で、割られる側の B（部分群のバイオマス）と、割る側の仮定個体質量を特定した。
* そのうえで、リポジトリの入力 xlsx から R で同じ計算をやり直した。
* 確認として、どの部分群でも「B ÷ 仮定質量」が `results.xlsx` の `Table S1`「Number of individuals」と有効数字6桁で一致した。

| 部分群 | B（再計算、g C） | 仮定質量（g C/個体） | B/質量 | results.xlsx の N |
|---|---|---|---|---|
| カイアシ類（中型動物プランクトンの節足動物） | 5.64617e14 | 4e-6 | 1.41154e20 | 1.41154e20 |
| ヒメミミズ類 | 1.92859e13 | 25e-6 | 7.71435e17 | 7.71435e17 |
| 翼足類 | 1.31985e14 | 2.65440e-4 | 4.97231e17 | 4.97231e17 |
| 浮遊性刺胞動物（クラゲ） | 4.0e13 | 2.03493e-3 | 1.96567e16 | 1.96567e16 |
| 中深層魚 | 5.17611e14 | 0.463939 | 1.11569e15 | 1.11569e15 |
| 線虫（全体） | 1.96117e13 | 5e-8 | 3.92233e20 | 3.92233e20 |

### 根拠（ノートブック本文の逐語引用）

* **海産節足動物**（`marine_arthropods.py` セル11の直前の markdown）："We consider only the mesozooplankton as they are the smallest group of marine arthropods ... we divide our estimate for the total biomass of mesozooplankton by an estimate for the characteristic carbon content of an individual copepod ... which range from 0.15 µg C to 100 µg C per individual. We use the geometric mean of this range, which is ≈4 µg C per individual"
  * コード：`marine_arth_num = meso_arth_biomass/copepod_carbon_content`
  * 保存された出力："Our best estimate for the biomass of mesozooplankton arthropods is ≈0.56 Gt C"
  * 食い違い：SI Table S14 には "Based on dividing the total biomass of each size category (mesozooplankton/macrozooplankton) by the characteristic carbon content of each class" とある。しかしコードは中型動物プランクトンだけを割っている。公表された N を作っているのはコードなので、コードに従った。
* **環形動物**："We consider only the Enchytraeids as they are ≈200-fold smaller than earthworms (Fierer et al.). We calculate the total biomass of Enchytraeids and divide it by the carbon content of Enchytraeids, which is ≈25 µg C (Fierer et al.)"
  * 内訳：平均ベース 2.20660e13、中央値ベース 1.68560e13、両者の幾何平均 1.92859e13 g C。
  * SI Table S16/S19 によると、Fierer の密度はもともと「個体数 ×（Petersen & Luxton の個体あたり C）」で作られている。したがって、ここでの N は元の個体数密度を戻しているのに近い。
* **軟体動物**："we consider the total biomass of pteropods and divide it by the average carbon content of a single pteropod ... Bednaršek et al. measured biomass of population densities pteropods per cubic meter. We divide these two measurements by one another"
  * 計算は「平均の比」で、比の平均ではない（8,814 行）。
  * 結果は 0.265 mg C。SI の「≈0.3 mg C」と整合する。
* **刺胞動物**："we divide the total biomass of jellyfish by the characteristic carbon content of a single jellyfish. We do not consider corals as they are colonial organisms ... We calculate the mean and median carbon content of all the species considered in the study, and use the geometric mean"
  * 中央値 0.556 mg C、平均 7.44 mg C（122 種）、幾何平均 2.03 mg C。
  * B は "Globally, they estimate ≈0.04 Gt C of gelatinous zooplankton, of which 92% are contributed by cnidarians. Therefore, we estimate the total biomass of plaktonic cnidarians at ≈0.04 Gt C."（0.92 は掛けていない）。
* **魚類**："we divide our estimate of the total biomass of mesopelagic fish by an estimate for the characteristic carbon content of a single mesopelagic fish ... Fock & Ehrich for the family Myctophidae ... We use the geometric mean of the weights of all species ... We convert wet weight to carbon mass assuming 70% water content and 50% carbon"
  * B = gmean(ソナー推定 1.78614e15, トロール推定 1.5e14) = 5.17611e14 g C。
  * 1個体の質量 = 3.093 g 湿重 × 0.15 = 0.464 g C（32 種）。
  * **コードの癖**：`np.mean([max, min])` に axis を指定していないため、全種・全値の平均体長 66.39 mm という1つの値をすべての種に使っている。種ごとの平均体長ではない。
  * 不確実性：`meso_CI = max(meso_inter_CI, sonar_CI)`。inter-method 側を、リポジトリの `geo_CI_calc`（ddof=1）で私が再計算すると 11.33 倍になる（保存出力は "≈11.3-fold"）。sonar 側は乱数を使い、出力は "≈9.5-fold"。したがって 11.33 を採用した。
* **線虫**：もともと N も B も線虫全体を指しているので、そろえ直しは不要。
  * 参考として、土壌部分だけの N（1.12233e20）を派生値として別行に出した（土壌の B 5.61166e12 g C ÷ 0.05 µg C）。
  * 海産部分 0.014 Gt C は仮定が多く、N の 71% を占める。

### 仮定した1個体質量の出典

いずれも Bar-On が引用しているもので、原典そのものは読んでいない（**未確認**）。

| 仮定 | 出典 |
|---|---|
| カイアシ類 | Viñas et al. 2010（doi:10.1590/S1679-87592010000200008）、Dai et al. 2016（doi:10.1016/j.jmarsys.2015.11.004） |
| ヒメミミズ類・線虫 | Fierer et al. 2009 Ecol Lett（doi:10.1111/j.1461-0248.2009.01360.x）。SI はさらに Petersen & Luxton 1982 を挙げている |
| 翼足類 | Bednaršek et al. 2012 ESSD（doi:10.5194/essd-4-167-2012）。データはリポジトリ内にあり、再計算は済み |
| クラゲ | Lucas et al. 2014 GEB。データはリポジトリ内にあり、再計算は済み |
| 中深層魚 | Fock & Ehrich 2010 J Appl Ichthyol（doi:10.1111/j.1439-0426.2010.01450.x）。データはリポジトリ内にあり、再計算は済み |

### 判断した点

* B の区間は、部分群について原典が出していないものは空欄にした。例えば海産節足動物の 10 倍は総量に対する値で、部分群には当てはめていない。
* 中深層魚の主値はゲート判断4で Irigoien 2014 に決まっている。この Bar-On の行は、N と仮定質量のために置いた。
* M = B/N は、どの行でも仮定質量そのものになる。これは phase1.md の問題1のとおりで、変わらない。

---

## 2. ダニ：Rosenberg 2023 の派生値（ゲート判断 5）

* **入力**：`data/raw/rosenberg2023/zenodo7565553.zip`（Zenodo 10.5281/zenodo.7502033）の `RawData.xlsx`、`aggregated biomes data.csv`、`results/tables/average_ind_mass_full.csv`。
* **実行環境**：システムの Python には pandas が入っていない。そこで、Zenodo の README に書かれたバージョン（Python 3.9、pandas 1.3.4、numpy 1.20.3）で、scratchpad に micromamba 環境を作った。R/renv には触れていない。
* **実行内容**：ノートブック `01-Main-Estimate...` のセル 0,1,3,5,7,9,10,12,13,15–19,21,23,34,44–47 を実行した。
  * 変更点：`%` マジックを削除、`save_bool=False`、RNG を固定（`default_rng(20261103)`、`np.random.seed(20261103)`）。
  * `N_boot = N_samps = 1e5` は原著のまま。
* **再現の確認**（同じ実行で得た値と、論文本文の値の比較）：

| 項目 | 今回の再実行 | 論文本文 |
|---|---|---|
| 土壌節足動物の個体数 | 1.0e19（5.0e18–1.8e19） | "≈1 × 10^19 (uncertainty range, 0.5 × 10^19 to 2 × 10^19)" |
| 土壌節足動物のバイオマス | 221（105–380）Mt | "≈200 (uncertainty range, 100 to 400)" |
| シロアリ | 99.9（48.8–168.5）Mt | "100 Mt; range, 50 to 170 Mt" |
| 非樹上性アリ | 4.6e16（1.7–9.2e16） | "5 × 10^16 (uncertainty range, 1 × 10^16 to 9 × 10^16)" |
| アリのバイオマス | 23.3（9.1–46.1）Mt | "≈25 Mt (uncertainty range, 10 to 50 Mt)" |
| トビムシ | 3.4e18（1.3–6.6e18） | "3 × 10^18 individuals; range, 1 × 10^18 to 6 × 10^18" |

* **ダニの結果（派生値）**：
  * N = 6.545e18（範囲 3.47e18–1.07e19）
  * B = 26.11 Mt 乾重（範囲 15.58–38.70）
  * 範囲の定義は論文 Methods に従った："calculated by taking the sum of the lower or upper bounds of the 95% confidence intervals for all such distributions"
  * 同じコードの Monte Carlo による 95% CI は、N 4.94–8.46e18、B 21.3–31.4 Mt。バイオームが独立と仮定しているので、幅は狭くなる。
  * 本文の割合とも整合する。"two-thirds" に対し 6.5/10、"about 10%" に対し 26/221。
* **M と湿重換算**：
  * M = B/N = 3.99 µg 乾重。
  * 湿重は、Rosenberg 自身が使う Acari の乾/湿 = 0.4 で割ると 65.3（39.0–96.8）Mt 湿重になる。0.4 の場所は `conversion_factors.csv` に書いた。
* **注意点**：
  * 個体数のデータしかないサイトでは、バイオマスは「タクソン平均の個体質量（Acari 0.00515 mg 乾重/個体）× 個体数」で作られている。そのため B と N は独立ではない。
  * 乱数による揺れは有効数字4桁目に出る（2,000 回リサンプルの試行では N 6.546e18、B 26.08）。

---

## 3. ミミズ：Phillips 2019 → **全球値なし**（ゲート判断 5）

試したことと、その結果：

| 試したこと | 結果 |
|---|---|
| iDiv 1804 v7（論文の DOI 10.25829/idiv.1804-5-2593） | 取得できた。中身はサイトレベルのモデルデータ `sWormModelData.csv` だけで、地図はない。`data/raw/phillips2019/idiv1804_v7_sWormModelData.zip` に保存 |
| iDiv 1818 v15（正誤表版データ 10.25829/idiv.1818-13-3001） | 取得できた。こちらも訂正版のサイトデータだけ。`idiv1818_v15_sWormModelData_correction.zip` に保存 |
| GitHub helenphillips/GlobalEWDiversity（commit 7149c8d）、Zenodo 10.5281/zenodo.3386456 | コードしかない。予測地図はローカルパス（`D:\sWorm\Results\Biomass\...predictedValues.csv`）から読んでおり、公開されていない |
| science.org の補足資料 | 403（Phase 1 と同じ） |
| figshare・Zenodo の検索 | 該当する地図は見つからなかった |

正誤表（著者リポジトリの `erratum_README.md`、逐語）：

> "Incorporation of the zero-sites has reduced our global estimates considerably. The mean global estimates are now, for richness 0.95 species (SD = 0.96; previously 2.42 species; SD = 2.19), for abundance 20.59 individuals per m2 (SD = 24.84; previously 77.89 individuals per m2; SD = 98.94), and for biomass 51.18 g per m2 (SD = 4881.2; median, 6.16; previously 2772.8 g per m2; SD = 1,312,782; median, 6.69)."

* これらは画素の単純平均であり（`11.1_ValuesFromMap.R` で `mean(all$V1)`）、面積で重み付けした合計ではない。陸域面積を掛けて全球値にすることはしなかった。
* 正誤表は Phase 1 の記録（`soil_arthropods.md` は旧値 77.89 を引用）を更新する情報なので、統合時に反映が必要。
* Science 誌上の正誤表本体は読めていない（**未確認**）。読んだのは著者リポジトリの文面だけ。

---

## 4. 換算係数（ゲート判断 7）→ `docs/conversion_factors.csv`

* **動物の基準**：C/湿重 = 0.15（Bar-On）。乾/湿 = 0.3、C/乾 = 0.5 の積で、Rosenberg の Discussion にも "Dry weight of 300 Mt is roughly equivalent to 1000 Mt of fresh weight (16) or 150 Mt of carbon (20)" とある。
* **Rosenberg の分類群別の乾/湿**（コードのセル5、"fine-tune taxa-specific conversion rates from wet to dry mass (from Petersen & Luxton)"）：

| 分類群 | 乾/湿 |
|---|---|
| Isoptera | 0.27 |
| Acari | 0.4 |
| Collembola | 0.32 |
| Formicidae | 0.228 |
| Araneae | 0.43 |
| Pseudoscorpiones | 0.224 |
| その他（既定値） | 0.3 |

  * Methods の記述："using a default value of 70% water content for groups with missing estimates"
  * SM 4.1："We use a conversion ratio of 0.27 from wet to dry biomass weight (16)"
  * 大元の Petersen & Luxton 1982 は読んでいない（**未確認**）。
* **トビムシ（Potapov）**：原典自身の換算 "c. 27.5 Mt C ... corresponds to c. 190 Mt fresh weight" を記録した。湿/C = 6.91（派生値）。
* **原核生物**：
  * Bar-On は細胞あたりの C（fg C cell^-1）しか扱っておらず、湿重への換算の基準は示していない（`bacteria_archaea/*/carbon_content/*.py` と SI を grep して確認）。
  * 代わりの根拠は2つ：
    * Bratbak & Dundas 1984 の抄録（Europe PMC、`data/raw/bratbak1984/europepmc_core_6508285.json`）："To convert bacterial biovolume into biomass (carbon content), we suggest that 0.22 g of C cm-3 should be used as a conversion factor." 同じ抄録は乾物率について "ranging from 31 to 57%" とも述べている。
    * Hatton 2021 のコード `phytoplankton_biomass_estimate.R` 107 行目："assuming 1 g wet weight = 1cm3 biovolume"。
  * この2つを組み合わせると C/湿 = 0.22 になる（派生値）。
  * 本文は ASM と Europe PMC の PDF がボット対策で取れなかったので、抄録だけを確認した。
* **感度分析用の代替**：Hatton 2021 のプランクトンの C→湿 ×10（C/湿 = 0.10）。コード94行目 "multiply by 10 to convert from carbon to wet weight"。その元になった文献（同論文の ref 73）は **未確認**。

---

## 5. 記載種数

* **出典**：Catalogue of Life 2026-10-14 の基本リリース（ChecklistBank データセット 316595、doi:10.48580/dgzh4）。拡張版の XR リリースは使っていない。
* **取得方法**：
  * `GET /dataset/316595/nameusage/search?q=<name>&type=EXACT&status=accepted` で、動物界の受理名に絞って taxon ID を得た。
  * 次に `GET /dataset/316595/taxon/<id>/metrics` の `speciesExtantCount`（現生の受理種数）を記録した。化石を含む数（`taxaByRankCount.species`）は notes に書いた。
  * 応答の JSON はすべて `data/raw/checklistbank_col26.10/` に保存してある。

| 群 | COL taxon | 現生種数 |
|---|---|---|
| Nematoda（門全体。土壌だけの数はない） | NM | 19,667 |
| Collembola | KZS5W | 8,926 |
| Acari = Acariformes + Parasitiformes | LK + LV | 22,635 + 6,382 = 29,017 |
| Formicidae | CLRKP | 14,438 |
| Termitoidae（= Isoptera） | C3V76 | 3,000 |
| ミミズ = Crassiclitellata | 84JRR | 1,994 |
| Enchytraeidae | 8KTLN | 840 |
| Copepoda | B8V3R | 15,297 |
| Pteropoda | 7NFFH | 141（化石を含めると 409） |
| Scyphozoa / Cubozoa / Staurozoa / Hydrozoa | B8V42 / B8V3T / B8V43 / B8V3X | 244 / 53 / 51 / 3,894 |
| Euphausia superba | 3CMD5 | 1 |
| Myctophidae | KVH45 | 252 |
| Mammalia | 6224G | 6,368 |
| Aves | V2 | 10,868 |

注意点と判断：

1. **網羅性に疑いがある（未確認）群がある**：
   * ダニ：COL 26.10 では "Acari" が受理名として存在しない。上位分類の扱いの違いと、収録データの欠けがある可能性がある。
   * ミミズ（Crassiclitellata 1,994）：亜綱 Oligochaeta 全体でも 4,432 種しかない。もう1つの目 "Opisthopora"（3Q4）は種数 0 だった。
   * 私の知識では、文献上の記載種数はダニもミミズもこれよりかなり多い。ただし本作業では文献の値を確認していないので、表には入れていない。
   * Zhang 2013（Zootaxa 3703）は Crossref にリンクがなく、取得できなかった（**未確認**）。
   * ダニとミミズは別の出典（例：Zhang 2011/2013 の表）で照合することを提案する。
2. **「クラゲ」の範囲**：Scyphozoa を主値にした。Lucas の gelatinous zooplankton にはヒドロクラゲも含まれるので、範囲をどう取るかで値は大きく変わる。
3. **中深層魚**：Bar-On が質量の計算に使った Myctophidae だけを数えた。中深層魚全体の科リストは、原典（Irigoien 2014）に定義がない。
4. **原核生物**：意図的に空欄にした。
