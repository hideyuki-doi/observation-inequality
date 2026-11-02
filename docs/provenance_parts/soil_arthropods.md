# Phase 1 センサス調査：soil_arthropods（陸生節足動物・土壌動物）

担当 id: `soil_arthropods`。作成日 2026-11-03。対応する表: `soil_arthropods.csv`（18行）。

すべての数値は以下の原典本文・補足資料・データから直接読み取った。読めなかったものは空欄にして「未確認」とした。引用は英語原文のまま。

---

## 1. Rosenberg et al. 2023, Science Advances 9: eabq4049

- DOI: https://doi.org/10.1126/sciadv.abq4049
- 全文: Europe PMC REST の PMC9897674 fullTextXML → `data/raw/rosenberg2023/PMC9897674_fulltext.xml`
- 補足 PDF とデータ S1: Europe PMC supplementaryFiles → `data/raw/rosenberg2023/pmc_supp.zip`（`sciadv.abq4049_sm.pdf` と `sciadv.abq4049_data_s1.zip` を含む）
- データとコード: Zenodo doi:10.5281/zenodo.7502033（record 7565553）→ `data/raw/rosenberg2023/zenodo7565553.zip`。収録ノートブックには出力が保存されておらず、結果表は `average_ind_mass_full.csv` しかない。ノートブックは実行していない。

### 逐語引用

- 土壌の合計（Results 第4段落）："We estimate the total mass of soil arthropods to be ≈200 (uncertainty range, 100 to 400) million metric tons (Mt) of dry weight ... Termites contribute about 40% of the biomass in the soil; ants, springtails, and mites contribute about 10% each; and other soil arthropods contribute the remainder ... We estimate the total population of soil arthropods to be ≈1 × 10^19 (uncertainty range, 0.5 × 10^19 to 2 × 10^19) individuals. The microarthropods, mites and springtails, account for >95% of the total population of soil arthropods, with about two-thirds of these being mites."
- 地上部（Results）："We find that above-ground arthropods have a total of ≈50 Mt (uncertainty range, 20 to 100) of dry biomass, with our upper range potentially reaching ≈200 Mt when considering key biases ... Together, both habitats contain a global terrestrial arthropod biomass of ≈300 Mt (uncertainty range, 100 to 500)." 個体数については "... population densities of above-ground arthropods are typically much smaller than those of soil arthropods and contribute little to the global number of individual arthropods."
- 全陸生節足動物（Discussion 第1段落）："Dry weight of 300 Mt is roughly equivalent to 1000 Mt of fresh weight (16) or 150 Mt of carbon (20) ... we estimate the total number of terrestrial arthropods at about 1 × 10^19 individuals (uncertainty range, 0.5 × 10^19 to 2 × 10^19)"
- シロアリ（Discussion 第2段落）："Our estimated global biomass of termites (100 Mt; range, 50 to 170 Mt) agrees with previous estimates of 100 to 120 Mt (14, 24)"
- シロアリの補足推定（SM 第4節）："we estimate the total global termite biomass to be about 80 Mt dry weight, with an extended error range between 50 and 120 Mt. This is about 20% lower than the median of our main estimate for termites"
- トビムシ（Discussion 第3段落）："Our total population estimate for soil springtails (3 × 10^18 individuals; range, 1 × 10^18 to 6 × 10^18 individuals) agrees with the recent estimate of 2 × 10^18 individuals made in (25), but our total biomass estimate is about four times lower. This difference seems to originate from the large values of average body mass reported in (25), which are based on taxonomy and allometric evaluations."
- アリ（Discussion 第4段落）："Our estimated global population of nonarboreal ants, considered as part of the soil and plant litter habitat, is 5 × 10^16 (uncertainty range, 1 × 10^16 to 9 × 10^16) individuals ... Our separate estimate for soil ants' dry biomass is ≈25 Mt (uncertainty range, 10 to 50 Mt) ... Our dataset yields a global average dry weight of 0.84 mg per soil ant."
- その他の節足動物（SM、ref 17 との比較）："This analysis yields an estimate of ≈75 Mt, which is similar to our estimate of ≈50 Mt for the group 'others'."
- 不確実性の定義（Methods）："The uncertainty ranges reported in the main text and in Fig. 5 were calculated by taking the sum of the lower or upper bounds of the 95% confidence intervals for all such distributions ... This procedure increased the uncertainty range by up to a factor of 4 with respect to the random error."

### 推定方法と method_class の判定

方法は、文献から集めた約500サイトの絶対密度（個体数/m²、mg/m²）の合成。土壌は方形区コアを採り、Tullgren 漏斗や手選別で抽出したもの。地上部はキャノピーフォギングや trap-and-remove による。これをバイオーム × 分類群に層別し、ブートストラップで平均を求め、バイオーム面積を掛けてモンテカルロで合算している。GBIF などの出現記録は使っていない。体サイズから密度を予測するアロメトリーも使っていない。

湿重量しかない記録は分類群別の係数で乾重量に換算している。個体数しかない土壌の記録は、同時測定データから求めた分類群平均の個体重で生物量に換算している。どちらも経験値であり、密度を予測するアロメトリーではない。以上から **independent** と判定した。

### 迷った点・未確認

- **ダニ（Acari）**：全球の N も B も数値として記載がない。分かるのは「>95% のうち約2/3」「土壌生物量の約10%」という割合だけである。約 6e18 は私の計算になるので表には入れていない。バイオーム別の密度は SM Table S3/S4 にある。全球値が必要なら、Zenodo のノートブックを実行するか、Table S4 × バイオーム面積で再計算する必要がある。どちらにするか（あるいはどちらもしないか）は人間の判断が必要。
- **トビムシの B、シロアリの N、「others」の N**：記載なし。
- **甲虫など**："others" に含まれ、個別の推定はない。
- **地上部の推定**：約60サイトに基づく。著者自身が「highly uncertain」としている。

---

## 2. van den Hoogen et al. 2019, Nature 572: 194–198

- DOI: https://doi.org/10.1038/s41586-019-1418-6
- 本文は有料で、取得できたのは抄録のみ（`data/raw/vandenhoogen2019/s41586-019-1418-6.html`）。HAL の公開版はボット対策で取得できなかった。
- 補足表（springer static-content）：`data/raw/vandenhoogen2019/41586_2019_1418_MOESM{1..9}_ESM.*`。MOESM1 は Reporting Summary。

### 逐語引用

- 抄録："The resulting maps show that 4.4 ± 0.64 × 10^20 nematodes (with a total biomass of approximately 0.3 gigatonnes) inhabit surface soils across the world, with higher abundances in sub-Arctic regions (38% of total) than in temperate (24%) or tropical (21%) regions."
- Supplementary Table 5 の説明："Summing the predicted number of nematodes per 1 km^2 pixel across biomes we estimate a total of 4.4 × 10^20 nematodes are present in the top 15 cm of soil across the globe." Total 行は Bacterivores 1.92E+20、Fungivores 6.38E+19、Herbivores 1.25E+20、Omnivores 3.94E+19、Predators 1.97E+19、Total_Number 4.41E+20（MOESM6_ESM.csv）。
- Supplementary Table 7 の説明："Nematode biomass per trophic group, per biome. Note that values are presented in megatons (10^6 tons) carbon." Total 行は Bacterivores 7.131、Fungivores 0.994、Herbivores 8.675、Omnivores 10.244、Predators 4.395、Total biomass 31.439 Mt C（MOESM8_ESM.csv）。
- Reporting Summary（MOESM1）："Each sample consisted of a 15-cm deep soil core, from which soil nematodes were extracted." "In each sample we counted number of nematodes and assigned them to trophic groups based on morphology." "we performed a stratified bootstrapping procedure ... This protocol thus allowed us to generate per-pixel 95% confidence intervals."

### 判定

**independent**。土壌コア 6,759 点の実測個体数を、73 の環境共変量レイヤーによる地理空間モデルで外挿している。Potapov 2023 の Methods には、この手法を "Random Forest" と書いている。環境変数だけを使った機械学習外挿であり、出現記録は使っていない。

### 迷った点・未確認

- 「4.4 ± 0.64」の ± が SD、SE、CI のどれなのかは本文が読めず未確認。CSV の N_lo/N_hi（3.76e20, 5.04e20）は私が ± から計算した値であり、interval_type は「未確認」とした。
- 抄録の「approximately 0.3 gigatonnes」が湿重量か乾重量かは未確認。CSV の B には単位が明記されている補足表7の 31.439 Mt C を採用した。生物量の計算方法（栄養群ごとの体重の出典）も、本文が読めないため未確認。
- 「soil nematode（土壌の上部15 cm）」は、GBIF の Nematoda（海産や寄生性を含む）とは範囲が一致しない（CLAUDE.md の落とし穴を参照）。
- データとコードは gitlab.ethz.ch にあるが、ボット対策で取得できなかった。

---

## 3. Schultheiss et al. 2022, PNAS 119: e2201550119

- DOI: https://doi.org/10.1073/pnas.2201550119
- 全文: Europe PMC PMC9546634 → `data/raw/schultheiss2022/PMC9546634_fulltext.xml`。SI Appendix と Datasets は Europe PMC からのダウンロードが極端に遅く、途中で中止した（未取得）。数値はすべて本文から読んだ。

### 逐語引用

- Results："we estimate the global epigaeic ant abundance at 3 × 10^15 (±0.7 × 10^15) (mean ± SEM), i.e., ∼3 quadrillion, individuals ... This corresponds to a dry biomass of 1.9 (±0.5) Mt C ... we estimate the number of all ants on Earth at any given time to be 19.8 × 10^15 (±5 × 10^15), i.e., ∼20 quadrillion, individuals with a total dry biomass of 12.3 (±3.1) Mt C"
- Methods："The upper and lower limits were estimated by summing biome means +SEM or –SEM, respectively."
- Methods："Thus, to account for nonforaging ants, we calculate total global ant abundance as [1] Global abundance=(epigaeic abundance+arboreal abundance)×100/22."
- Methods："an average worker ant was considered to have a dry weight of 1.24 mg (Dataset S4), a value obtained from the body mass measurements of 534 species ranging from 0.004 to 57 mg ... Biomass [Mt C]=abundance×0.62×10−15."
- 樹上のアリ："With the limited data available on arboreal ant densities, these calculations were not intended to provide reliable numerical values but merely a general indication of the size of the global arboreal ant population."
- 記載種数（Introduction）："Ants are highly diverse, comprising more than 15,700 named species and subspecies (26)"

### 判定

- **地表性（epigaeic）の値は independent**。リターを抽出して得た面積あたりの密度を、バイオーム面積で外挿している。ピットフォールトラップは活動密度なので、全球の推定には使っていない。
- **全アリの値は mixed とし、人間の確認待ち**。実測値に、文献から取った「採餌個体の割合 22%」で補正（×100/22）している。この補正は出現記録由来でもアロメトリー由来でもないので、independent と扱ってもよいかもしれない。
- 生物量は N × 固定の個体重（534種の単純平均で、個体数の重みなし）である。Rosenberg は、この換算が群集全体の重み付けをしていないと批判している。

---

## 4. Potapov et al. 2023, Nature Communications 14: 674（トビムシ）

- DOI: https://doi.org/10.1038/s41467-023-36216-6
- 全文: Europe PMC PMC9905565 → `data/raw/potapov2023/PMC9905565_fulltext.xml`
- データ（未ダウンロード）：figshare doi:10.6084/m9.figshare.16850419（データとコード）、10.6084/m9.figshare.16850446（地図）

### 逐語引用

- Discussion："Our extrapolations suggest that there are c. 2 × 10^18 soil springtails globally, and their total biomass comprises c. 27.5 Mt C (16.2–28.8 Mt C minimum and maximum estimates), which corresponds to c. 190 Mt fresh weight ... Our biomass estimates are very similar to the global estimated biomass of nematodes (c. 31 Mt C10), but lower than that of earthworms (c. 200 Mt C11)"
- 生物量の計算方法："Body masses and metabolic rates were derived from taxon-specific body lengths using mean annual soil temperature and allometric regressions" と "Dry and fresh body masses were calculated from body length using a set of group-specific length-mass regressions"
- 不確実性："we also used maximum (average + standard error) and minimum coefficients (average—standard error ...) in all equations to calculate maximum and minimum estimations of biomass"
- 外挿："A Random Forest algorithm was applied to identify the spatial associations and extrapolate local observations to the global scale at the 30 arcsec resolution" と "Global biomass, abundance, and community metabolism of springtails were estimated by summing predicted values for each 30 arcsec pixel10."

### 判定

**N は independent**。2,470 サイト・43,601 の土壌サンプルから抽出した実測密度を、22 の環境レイヤーによる Random Forest で外挿している。

**B は、個体の体重を体長–体重アロメトリーで推定している**。これは「密度を体サイズから予測する」タイプではないので、CLAUDE.md が警戒する循環には当たらないと考える。ただし M = B/N を使う解析では、M がアロメトリーで作られた値になる。そこで CSV では independent とし、notes に注記した。人間の判断が必要。B の幅（16.2–28.8）は回帰係数の ±SE だけを反映した値であり、標本誤差は含まない。N の区間は記載されていない。

なお、Rosenberg 2023 は同じトビムシについて N = 3e18（1–6e18）とし、生物量は Potapov の約1/4と述べている（上の引用を参照）。

---

## 5. ミミズ：Phillips et al. 2019, Science 366: 480–485

- DOI: https://doi.org/10.1126/science.aax4851
- 著者原稿: PMC7335308（HTML）→ `data/raw/phillips2019/PMC7335308.html`。補足 PDF は PMC のボット対策と science.org の 403 で取得できなかった。

### 逐語引用（いずれも1 m² あたりの値で、全球の合計ではない）

- "The predicted total abundance of the local community of earthworms typically ranged between 5 and 150 individuals per m^2 across the globe ... (Fig. 1C; mean, 77.89 individuals per m^2; SD, 98.94)."
- "The predicted total biomass of the local earthworm community (adults and juveniles) across the globe showed extreme values (>2 kg) in 0.3% of pixels, but biomass typically ranged (97% of pixels) between 1 g and 150 g per m^2 [Fig. 1D; median, 6.69; mean, 2772.8; SD, 1,312,782 ...]"
- データ："Data and analysis code are available on the iDiv Data repository (DOI: 10.25829/idiv.1804-5-2593) and GitHub (https://github.com/helenphillips/GlobalEWDiversity; DOI: 10.5281/zenodo.3386456)."

### 判定

本文には全球の合計（N も B も）が記載されていない。補足資料は未確認。方法は 6,928 サイトの実測値を、12 の環境変数を使った GLMM で予測するもので、independent に相当する。

Potapov 2023 は "earthworms (c. 200 Mt C11)" と書き、出典として Phillips 2019 を挙げている。しかし Phillips の本文にはこの数値が見当たらず、二次情報なので未確認とした。外れ値が大きいピクセル（>2 kg/m²）があるため、地図を足し合わせて全球値を作ると不安定になる。

---

## 6. その他（シロアリ・ダニなど）

- **シロアリ**：Rosenberg 2023（100 Mt、50–170）と SM の 80 Mt（50–120）を採用した。Rosenberg が引用する先行推定（ref 14, 24: 100–120 Mt）は原典を確認していないので、表には入れていない。
- **ダニ**：全球推定を報告した独立の論文は、今回の調査では見つからなかった（深くは探していない）。
- **線虫・トビムシ以外の土壌メソファウナ**（ヒメミミズ類など）は未調査。

## 人間に判断してほしいこと

1. ダニの全球 N/B を、Rosenberg の Zenodo コードの実行か Table S4 × バイオーム面積の再計算で作るか（作れば「派生値」として記録する）。
2. Potapov のトビムシ B（体長–体重アロメトリーで個体重を推定）と、Schultheiss の全アリ（採餌個体の割合で補正）の method_class をどう扱うか。
3. トビムシは Rosenberg（3e18、乾重量）と Potapov（2e18、27.5 Mt C）のどちらを主に使うか。アリは Rosenberg（非樹上性、5e16）と Schultheiss（全体 2e16、地表性 3e15）のどれを使うか。範囲の定義が異なる点に注意（Rosenberg の値が Schultheiss の地表性推定より1桁大きい）。
4. ミミズは全球値なしとするか、Phillips の地図（iDiv/Zenodo）を自分たちで合計するか。
