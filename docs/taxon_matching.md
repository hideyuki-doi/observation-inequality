# センサスのグループと GBIF 分類群の対応規則（草案 2026-11-03）

GBIF スナップショット 2026-11-01 では分類体系が **COL XR**（種キーが英数字、例 `NNWPK`）。列は kingdom/phylum/class/order/family/genus/species の名前のみで、上位分類のキーはない。対応づけは名前で行う。

各グループについて、主規則（main）と、感度分析で揺らす変種（var）を定める。

| センサスのグループ | main | var | 備考 |
|---|---|---|---|
| 原核生物 | kingdom ∈ {Bacteria, Archaea} | 細菌と古細菌に分ける | 記録はほぼ配列由来。H4 と感度分析のみ |
| 土壌線虫（van den Hoogen） | phylum = Nematoda（全体） | (a) 脊椎動物・植物寄生性の科を除く（科リストは別途作り、出典を記録）、(b) 陸上座標の記録のみ | main は海産や寄生性の線虫まで含むので、r を過大評価する方向にずれる |
| トビムシ（Potapov） | class = Collembola | — | |
| ダニ（Rosenberg から派生） | order ∈ {Sarcoptiformes, Mesostigmata, Trombidiformes} | ＋Ixodida, Opilioacarida, Holothyrida（Acari 全体） | マダニ（Ixodida）は土壌性ではないので main から外す |
| アリ（Rosenberg の非樹上性） | family = Formicidae | — | 樹上性アリの記録も含んでしまう |
| ヒメミミズ類（Bar-On の環形動物 N） | family = Enchytraeidae | — | |
| カイアシ類（Bar-On の海産節足動物 N） | class = Copepoda | 淡水の目を除く案（要検討） | 寄生性カイアシ類も含む |
| 翼足類（Bar-On の軟体動物 N） | order = Pteropoda | — | |
| クラゲ（Bar-On の刺胞動物 N） | class ∈ {Scyphozoa, Cubozoa} | ＋Hydrozoa（ポリプ世代を含む）、＋Ctenophora, Thaliacea（Lucas 2014 の範囲） | 範囲は Bar-On のノートブックで確認中 |
| 中深層魚（Irigoien） | Irigoien 2014 が対象とした科（原典から科リストを取る） | Myctophidae のみ | 未確定 |
| ナンキョクオキアミ | species = *Euphausia superba* | — | |
| 陸生哺乳類 Tier A | 種名で照合（COL XR ↔ Greenspoon/COMBINE）。同義語は COL の同義語表で解決 | — | 照合規則は Phase 2 の結果を見てから確定 |
| 海生哺乳類 | 同上 | — | |
| 鳥類（感度分析のみ） | 種名で照合（COL XR ↔ AVONET eBird/Clements 2021） | — | |

## 方針

* 記録数 R は occurrenceStatus = ABSENT を除いた記録数。種まで同定された記録だけ（taxonRank = SPECIES 以下）と、上位分類までしか同定されていない記録も含めた全体の両方を数える。グループ単位の主解析は全体を使う。
* 座標による陸／海の区別は、現在の集計に入っていない。必要なら、対象の門（Nematoda、Copepoda など）だけを抜き出して座標付きで集計し直す。
