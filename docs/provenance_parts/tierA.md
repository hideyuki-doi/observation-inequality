# tierA — 種レベルの N（Tier A）と体重データベース

担当: tierA ／ 作業日: 2026-11-03
ルール: 値はすべて原典・補足資料・データリポジトリから読んだもの。tierA が自分で計算した値はそのつど「tierA 計算」と書く。

---

## 1. 鳥類: Callaghan, Nakagawa & Cornwell 2021 PNAS

- 引用: Callaghan CT, Nakagawa S, Cornwell WK (2021) Global abundance estimates for 9,700 bird species. *PNAS* 118(21): e2023170118. doi:10.1073/pnas.2023170118（PMC8166167、CC BY 4.0）
- 本文: Europe PMC の全文 XML → `data/raw/callaghan2021/PMC8166167_fulltext.xml`
- 補足資料（Europe PMC 経由で取得、変更なし）: `data/raw/callaghan2021/PMC8166167_supplementary.zip`（md5 f36c02029cc2224bfb5c44a95f72e4eb）。中身は SI Appendix PDF（`pnas.2023170118.sapp.pdf`）、Dataset S1（`pnas.2023170118.sd01.xlsx`）、図
- データとコード（Zenodo）: doi:10.5281/zenodo.4723365（v1）。取得したのは `data/raw/callaghan2021/zenodo_4723365/` の `Tables.zip`（md5 d20c2d78…）、`R.zip`（md5 c1238666…）、`readme.docx`。取得していないのは `Data.zip`（248 MB）、`Intermediate data files.zip`（5.4 GB）、`eBird data.zip`（8.7 GB）、`Figures.zip`
- 種別の表: `Tables/all_species_summary_table.csv` が 9,700 行（全種で学名が異なる）。列は Common name, Scientific name, Order, Family, 95% Lower CI, Abundance estimate, 95% Upper CI, Range adjusted, Training species。PNAS の Dataset S1 xlsx と照合し、9,700 種すべてで Abundance estimate が一致した（tierA が確認）。
  - Range adjusted: TRUE 6,969 / FALSE 2,731
  - Training species: TRUE 684 / FALSE 9,016
  - Abundance estimate がゼロの種が 5 つ。欠損はない。
- **種ごとの 95% CI は 9,700 種すべてにある。**

### 数値

| 項目 | 値 | 出典・方法 |
|---|---|---|
| 種数 | 9,700（"∼92% of all extant bird species"） | 要旨 |
| 総個体数（中央値） | "∼50 billion" | 本文 |
| 総個体数（平均） | "∼428 billion" | 本文："Compared with the median estimate, the mean estimate of the aggregated distribution for all birds in the world was ∼428 billion individual birds" |
| 種の中央値の合計 | 50,516,171,834 | tierA 計算（Dataset S1）。順序をそろえた合計（下記）なら、これが論文の中央値に当たる |
| 種の 95% 下限の合計 / 上限の合計 | 3.91×10⁹ / 2.75×10¹² | tierA 計算。**本文には数値の記載がない** |
| 総数の区間（批判論文が図から読んだ値） | "3.9 billion to 2,080 billion; figure 2 of ref. 1" | Robinson et al. 2022 |
| 種あたりの平均 / 中央値 | 520万 / 45万 | 本文："The average of all 9,700 global population estimates was 5.2 million, whereas the median was 450,000"（tierA の再計算でも 5,207,853 / 450,954.5 で一致） |

区間について: 上限は、tierA の合計（2,749 billion）と Robinson が図から読んだ値（2,080 billion）で食い違う。区間の作り方が違う可能性がある（たとえば図 2 は HDI）。統合のときは、種別の CI を使うか、論文の図の値を使うかを人間が決めてほしい。
論文の合計の仕方（逐語）: "we summed the species-specific distributions as described above, ensuring the distributions were ordered before summing (i.e., the smallest values or largest values are summed as we combined distributions)."

### 推定方法（Methods の逐語引用）

5 つのステップ:
> "Step 1 (Training data): Model the relationship between known (i.e., externally validated best available data) density estimates and relative abundance from eBird to derive a species-specific training model, while incorporating known error in the relative abundance estimates.
> Step 2 (Imputation data): Calculate a measure of relative abundance for all species in 5° grid cells throughout the world. For the training species, calculate density using the results from Step 1 in each unique grid a species occupies.
> Step 3 (Life history traits): Collate life history traits (bird color, flock size, body size, and International Union for Conservation of Nature [IUCN] status) that are likely to influence the relationship between the true population of a species and the relative abundance of a species calculated through eBird.
> Step 4 (Multiple imputation): Perform multiple imputation by chained equations to predict the density of a species and its uncertainty per grid cell, based on the known relationship between estimated density and observed relative abundance for our training species and the traits collated at Step 3.
> Step 5 (Calculate abundance): Use the predicted densities and uncertainties to derive a mean global density estimate for each species and multiply this density estimate by the observed area of a species—with extrapolation where necessary and possible—to calculate a simulated global abundance distribution."

訓練データ:
> "We used published abundance estimates from three sources: 1) the Partners in Flight Population Estimates Database ( 62 ); 2) population estimates from the British Trust for Ornithology ( 63 ); and 3) from BirdLife International Data Zone datazone.birdlife.org/home . We collated a total of 724 species for which we had estimated population abundance."

eBird の相対個体数:
> "we used the mean abundance across all checklists (including checklists when a species was not identified; zeros) as our measure of relative abundance."
> "For our analysis, we used the eBird basic dataset (version ebd_relMay2019). We aggregated eBird data from January 2010 to May 2019."

全種がグリッド単位で eBird に依存していること:
> "Within each grid (N = 579), we calculated the relative abundance of each species as defined above ... If a species was not observed in a grid (i.e., a relative abundance of 0), then we assumed that the species does not exist in that grid."

補完データセット（全種で eBird の相対個体数が使われ、体重が補助変数として入っている）:
> "Our 'imputation' dataset included 192,702 rows (grid × species) with 11 variables: 1) species ID (0% missing), 2) the log-transformed number of eBird checklists (0% missing), 3) the number of months a species was observed in that grid (0% missing), 4) relative abundance as described in detail above (0% missing), 5) flock size (0% missing), 6) IUCN status (8% missing), 7) body size (16% missing), 8) color distance from brown (40% missing), 9) color brightness (40% missing), 10) estimated density (79% missing), and 11) the SE for the density (79% missing). ... Our targets for imputation were density (at the specific grid level) and its SE (10 and 11), mainly informed from relative abundance (0% missing values) but also helped by the five auxiliary variables (5 through 9)."

体重:
> "For body size, we used the adult body mass (in grams) as extracted from ref. 87 ." （ref. 87 = Myhrvold N. P., et al., An amniote life-history database …）
> "A species' intercept showed strong correlation with body mass ( r = −0.467)"
> "For flock size, we used eBird to calculate the overall mean flock size among all presences in the dataset for each species."

面積:
> "We then calculated the total area occupied by each species in our analysis by summing the area of the number of grid cells each species was found in. ... for a species whose estimated range was not fully sampled by our eBird analysis ... we used the area of the total range size ... Estimated species' ranges were provided by BirdLife International. ... our range adjustment was not done for 2,731 species, in which case we assumed that the total area of their sampled grid cells approximates the total species range size."

訓練種の推定値も eBird のモデルを通して作り直されている（Step 2 "For the training species, calculate density using the results from Step 1"）。外部の専門家推定値をそのまま使ってはいない。

訓練データ側の出典の方法（SI Appendix の逐語引用）:
- PIF: "It predominantly relies on data from the North American Breeding Bird Surveys scheme, based on the decade 2006—2015"
- BTO: "We extracted population estimates from Musgrove et al. 2013 ... had a reliability of '1' or '2'"
- BirdLife: "These data are compiled by global experts for each species ... usually presented in standard bands of estimated ranges ... Where a standard band estimate was provided, we used the midpoint"

分類体系: コードは `Data/clements_clean.csv` を読み込んでおり（`R/get_species_specific_abundance_distribution_estimates.R` ほか）、eBird/Clements 体系を使っている。ebd_relMay2019 に対応する Clements の版番号は原典で確認できなかった（**未確認**）。

### method_class の判定: **occurrence-derived**（体重による部分的なアロメトリー成分あり）

理由:
1. 問いの (a) か (b) か → **(a) 全種**。9,700 種すべてで、密度は eBird の相対個体数（欠損 0%）を主な予測子にして推定され、面積も eBird のグリッド（または BirdLife の分布域）から作られている。訓練種 684 種の推定値も eBird のモデルを通している。
2. 体重は補完の補助変数になっている（欠損 16%）。論文自身も切片との相関 r = −0.467 を報告しており、体重は eBird と密度の関係を補正する役割を持つ。つまり、推定値には体重の情報が部分的に入っている。H1 で N と M のスケーリングを調べると、この成分が人工的な相関を生みうる。
3. 群れサイズも eBird から計算されている。
4. したがって、本プロジェクトの主解析（independent のみ）には使えない。CSV では method_class = occurrence-derived とし、体重成分は notes に書いた。"mixed"（occurrence + allometry）とすべきかは人間の判断を仰ぎたい。

### 批判と反論（原文を Europe PMC で確認）

- Robinson OJ, Socolar JB, Stuber EF, … Johnston A (2022) Extreme uncertainty and unquantifiable bias do not inform population sizes. *PNAS* 119(10): e2113862119. doi:10.1073/pnas.2113862119（PMC8915789 → `data/raw/callaghan2021/PMC8915789_fulltext.xml`）
  > "Abundance estimates ( 1 ) fell outside minimum–maximum ranges provided by BirdLife International for 81% of the 2,423 species with available estimates (27% below the minimum, 54% above the maximum)"
  > "96% of individual species had posterior uncertainty spanning three or more orders of magnitude."
  > "San Andres Vireo ( Vireo caribaeus ), used in model training with a population size of 2,500 to 10,000 mature individuals ( 4 ), was estimated as extinct ( 1 )."
- Callaghan CT, Nakagawa S, Cornwell WK (2022) Reply to Robinson et al.: Data integration will form the basis of future abundance estimates. *PNAS* 119(10): e2117920119. doi:10.1073/pnas.2117920119（PMC8915984）
  > "our modeled estimates are strongly correlated with BirdLife abundance estimates ( r = 0.72; Fig. 2 )" （2,860 種）
- 全鳥類を対象にした、より新しい種別の全球個体数推定は、ウェブ検索（2026-11）では見つからなかった。見つからなかったことは「存在しない」という確認ではない。

### 鳥類の代替案（未確認）

BirdLife/IUCN の専門家による個体数推定（多くは幅で示された値）が、eBird に依存しない種別の N の候補になりうる。Robinson et al. は 2,423 種、Callaghan の反論は 2,860 種を対応づけている。ダウンロードはしていない（Data Zone と IUCN API の利用条件を確認する必要がある）。

---

## 2. 鳥類の体重: AVONET（Tobias et al. 2022 Ecology Letters）

- 引用: Tobias JA, et al. (2022) AVONET: morphological, ecological and geographical data for all birds. *Ecology Letters* 25(3): 581–597. doi:10.1111/ele.13898
- figshare: doi:10.6084/m9.figshare.16586228.v7（更新日 2022-12-05）
- 取得ファイル: `data/raw/avonet/AVONET_Supplementary_dataset_1.xlsx`（md5 1445afdcfb6df784010c2ca034544bc8、figshare の computed_md5 と一致）、`data/raw/avonet/Supplementary_dataset_2.xlsx`（md5 7aaddac5…、一致）
- シートと行数: AVONET1_BirdLife 11,009 / **AVONET2_eBird 10,661** / AVONET3_BirdTree 9,993 / AVONET_Raw_Data / Mass_Sources / 2 つの対応表（BirdLife–eBird、BirdLife–BirdTree）
- AVONET2_eBird の分類体系（Metadata シートの逐語引用）: "eBird/Clements v2021 (Aug 2021)"。体重: "Body mass given as species average (incorporating both male and female body mass)"（単位 gram）。出典は Dunning 2008、EltonTraits、更新文献などで、Mass.Source 列に記録されている。
- **Callaghan の学名との一致（tierA が完全一致で照合）**: AVONET2_eBird 9,302/9,700、AVONET1_BirdLife 8,944/9,700、AVONET3_BirdTree 7,724/9,700。
  → **eBird 版（AVONET2）が Callaghan に合う。** 一致しない 398 種は、2019 年から 2021 年の Clements 改訂による属名の変更が主な原因（例: Oreothlypis → Leiothlypis、Sylvia → Curruca、Phalacrocorax の分割、Oceanodroma）。eBird の分類体系の改訂履歴（taxonomy update）で対応づける必要がある（未実施）。
- 注意: AVONET の体重の一部は推定値（Mass.Source が EltonTraits_Model、Inferred、DataFromSplit）。Callaghan が補完に使った体重は Myhrvold et al. のもので、AVONET ではない。

---

## 3. 哺乳類の種別個体数

### Greenspoon et al. 2023 PNAS（利用可能性のみ。詳細は Milo 担当）
- doi:10.1073/pnas.2204892120（Europe PMC で確認）
- `data/raw/greenspoon2023/mammal_biomass/results/wild_land_mammal_biomass_inluding_populations.csv`（別の担当が取得）: 4,795 行。列は binomial, biomass_g, biomass_g_97pt5, biomass_g_2pt5, estimated_population_2pt5, estimated_population, estimated_population_97pt5。**陸生哺乳類の種別 N と 95% 区間がある。**
- `results/results_by_method.csv`: "Population reports" 393 種、"Inferred using SVR" 4,413 種（合計 4,806 で、4,795 行と合わない。理由は**未確認**）
- `results/all_included_features_RMSE_table.csv`: SVR の特徴量は range、body_mass、trophic_level、red_list_status、order → 推定された部分は **allometry/trait-derived**。報告値の部分は IUCN などの個体数報告。全体としては **mixed**。
- estimated_population の合計 8.78×10¹⁰ は tierA 計算で、論文に記載された値ではない。
- 海生哺乳類: `results/wild_marine_biomass.csv`（121 行、biomass_Mt）。N の列は見当たらない（詳細は Milo 担当）。

### その他
- TetraDENSITY（Santini, Isaac & Ficetola 2018 GEB 27:787–791、doi:10.1111/geb.12756）: 局所的な**密度**（個体/km²）の文献集成で、N ではない。ダウンロードしておらず、原典も読んでいない（**未確認**）。TetraDENSITY 2.0（GEB 33: e13929）はウェブ検索で見ただけ（**未確認**）。
- COMBINE には `density_n_km2` 列があり、1,263/6,263 種に値がある（tierA が数えた）。これも密度。
- IUCN Red List の個体数欄: API トークンが必要なため、アクセスしていない（**未確認**）。
- 全球の種別 N を持つ哺乳類データセットは、Greenspoon 2023 以外に見つからなかった。

---

## 4. 哺乳類の体重: COMBINE（Soria et al. 2021 Ecology）

- 引用: Soria CD, Pacifici M, Di Marco M, Stephen SM, Rondinini C (2021) COMBINE: a coalesced mammal database of intrinsic and extrinsic traits. *Ecology* 102(6): e03344. doi:10.1002/ecy.3344（著者・巻号・ページは Europe PMC のメタデータで確認した。本文は読んでいない）
- figshare: doi:10.6084/m9.figshare.13028255.v4（更新日 2021-04-23）
- 取得ファイル（`data/raw/combine/`、すべて figshare の md5 と一致）: `trait_data_reported.csv`（6,263 行）、`trait_data_imputed.csv`、`trait_data_sources.csv`、`taxonomy_crosswalk.csv`、`trait_databases.csv`
- 分類体系の列: `iucn2020_binomial`、`phylacine_binomial`
- `adult_mass_g` の値: 6,033/6,263 種。reported 版と imputed 版で体重の値は同じ（体重は補完されていない。tierA が確認）
- Greenspoon 2023 の 4,795 種のうち 4,793 種が COMBINE の iucn2020_binomial と一致した（tierA が確認）

---

## 5. その他の分類群（存在の確認のみ）

- RAM Legacy Stock Assessment Database v4.66（Zenodo、2024-11-06、doi:10.5281/zenodo.14043031。Extended 版は 10.5281/zenodo.14043038）: 漁獲対象の資源（stock）ごとの資源評価のバイオマス。種の全球値ではなく、ダウンロードもしていない。
- 両生類・爬虫類: 全球の種別 N のデータセットは見つからなかった（検索は限定的）。

---

## 人間に判断してほしいこと

1. Callaghan 2021 を occurrence-derived とするか、mixed（occurrence + allometry）とするか。どちらにしても主解析からは外れ、Tier A の鳥類で independent な種別 N は今のところない。
2. 鳥類で eBird に依存しない N の代替として、BirdLife/IUCN の個体数推定（幅で示された値）を入手するか。
3. Callaghan の総数の区間: 種別 CI の合計（3.9×10⁹–2.7×10¹²）を使うか、Robinson が図 2 から読んだ値（3.9–2,080 billion）を使うか。
4. Greenspoon 2023 の哺乳類種別 N は、SVR で推定した部分（4,413 種）が体重を予測子にしているため allometry-derived。報告値の 393 種だけを independent として扱う案を検討してほしい。
5. Clements 2019 と 2021 の名前の対応（398 種）を、eBird の分類体系改訂の対応表で解決すること。
