# 土居さんのコメント（v4_main_submission_HD.docx）への対応メモ（2026-11-04、v5 → v6）

## 直接の修正（変更履歴なしの書き換え）

| 修正 | 対応 |
|---|---|
| 所属を「Graduate of Informatics, Kyoto University, Yoshida-honmachi, Kyoto, 606-8501, Japan」に | 反映。「Graduate of」は「Graduate **School** of」の誤記と判断して直した（違っていれば戻します） |
| 「[CrI]」→「[CI]」 | 本文・SI・SI 表のすべてで「CI」に統一（credible interval の略として本文で定義） |
| 「(with English translation)」を削除（2 か所） | 反映。SI でも同じ表現をやめた |
| Zenodo の文言を削除 | 反映 |

## コメントへの対応

| # | コメント | 対応 |
|---|---|---|
| 1 | 要旨の「事前登録した指数が比の人工物だった」は不要では | 要旨から削除。「この差は個体数や体の大きさを反映しておらず、記録は記載種数とともに増えた」という結果だけを書いた。比の人工物の説明は結果に残した |
| 4 | GBIF に URL などの引用を | 序論の初出で https://www.gbif.org と GBIF スナップショットの DOI（文献 1）を引用。文献 1 は DOI が印字される形式に変えた |
| 5 | 「The question matters most…」の前置きがない | 序論の第 1 段落の最後で「記録が個体数とどう対応するかは調べられていない」と問いを立て、第 2 段落を「This gap in knowledge matters most for small animals, because…」で始めて、なぜ小型動物で特に重要かにつないだ |
| 6 | 「The second question…」も前置きが必要 | 第 4 段落を「How records are distributed also determines what they can be used for, and their most consequential use is to detect population declines」で始め、記録の分布の問いから減少検出の問いへの橋渡しを書いた |
| 7 | 仮説とやったことを明確に | 序論の最終段落を書き直した。「見えやすさ仮説」（記録は個体数×目立ちやすさ、投影面積なら体重^2/3）と「配分仮説」（記録は同定できる種数に比例）を明示し、続けて検出のシミュレーション、構造化モニタリングでの検証、全記載種への適用、という手順を書いた |
| 10 | 結果から始まる形式なので、解析方法も入れつつ分かりやすく | 結果の最初の節で、GBIF スナップショットをどう集計し、10 群のセンサスとどう組み合わせたかを書いてから数値に入る形にした。各節の冒頭に、その節で使った解析（モデル名・比較方法）を一文で入れた |
| 12 | 統計モデルの名前も書く | 「Bayesian errors-in-variables regression」と明記（結果・方法）。哺乳類内は log–log 回帰、検出は負の二項回帰（努力量オフセットつき）、UKBMS は準ポアソン GLM と明記 |
| 13 | 「(exploratory)」は必要？ | 本文の「(exploratory)」の表示をすべて削除。v6 では「事前登録」の枠組み自体を本文・SI・カバーレターから外し、追加の解析はすべて sensitivity / preliminary analyses として記述した（下の v6 の節を参照） |
| 19 | 箇条書きやめて | 本文の箇条書き（種の割合のリスト）を文章にした。SI の方法の箇条書き（54 行）もすべて文章に直した |
| 21 | 「Simple analyses produce spurious trends」はどこかの節に組み入れては | 独立の節をやめ、UK のチョウでの検証の節（「Record-based trends are unreliable even where records are rich」）の第 1 段落に組み入れた |
| 30 | 世界地図などで、GBIF の世界のデータを使っていることを示してから | 新しく図 1 を追加。10 群（上）と哺乳類（下）の記録数を 1° セルで示す世界地図。結果の最初の節で、記録が全大陸・全海洋の 16,832 セル（哺乳類 27,467 セル）にわたり、67% が北緯 30 度以北にあることを述べた |
| 31 | 図の下の細かい説明を削除して legend へ。他の図も同様に | すべての図（本文・SI）から図の中の説明文を削除し、legend に移した。パネル内には統計値など必要最小限だけ残した |
| 32 | b の図が小さい。Fig 3 と 4 に分けてもいい | 旧図 3 を分割。DNA の図を図 3（2 パネルを横並びで拡大）、検出可能な種の割合を図 5 とした。それに伴い図の番号は 図 1 地図、図 2 記録の配分、図 3 DNA、図 4 検出、図 5 検出可能性 |

## 書式の変更（ご指示）

- フォント：本文は Times New Roman（Word のスタイルを作り直した）。図は v6 で Helvetica に変更（下記）
- 見出し：色付けを削除。見出しは黒の太字のみ、本文と同じ 12 pt
- 箇条書き：本文・SI ともなし（Word 上で番号・箇条書きの段落ゼロを確認）
- 図：本文の最後（参考文献の後）にまとめ、各図の真下に legend。SI の図も同様

## その他の修正

- 「査読（review）」の表現：実際の初回投稿では誤解を招くので、本文から「査読で指摘された」の表現を除いた。v6 では「internal pre-submission review」の記述も削除
- 本文の長さ：序論〜考察で約 3,500 語、方法を含めて約 4,100 語、図 5 枚。PNAS の標準（6 ページ）をやや超える可能性があり、超過ページは追加料金（PNAS の規定を投稿前に確認してください）

## 投稿先の判断

- **推奨：PNAS（Direct Submission、Research Article、Biological Sciences / Ecology）**
- 理由
  - 本研究が土台にしている全球センサス（Bar-On 2018、Greenspoon 2023、Callaghan 2021、Schultheiss 2022）は PNAS で発表されており、続く研究として位置づけやすい
  - 主結果（記録は種に配分される、減少検出の限界）は、生態学・情報学・保全政策をまたぐ幅広い読者向け
  - 当初の見かけのスケーリングが比の人工物だったことを正直に報告する構成は、PNAS の方が受け入れられやすい
- Nature Ecology & Evolution は「一つの大きな発見」を求められて desk reject されやすいと判断した
- 参考文献の書式：「L. Greenspoon, et al., The global biomass of mammals since 1850. Nature Communications 16, 8338 (2025).」は PNAS 形式（Nature 形式なら「Greenspoon, L. et al. … Nat. Commun. 16, 8338 (2025).」）。PNAS 投稿ならこのままで合っている

## カバーレター

- `manuscript/versions/v6_cover_letter_PNAS.docx`（v5 から事前登録の段落を削除）
- 日付は空欄
- 推薦査読者・忌避査読者は投稿システムに入力するので書いていない。必要なら候補を挙げます

## v6 の追加修正（2026-11-04）

| ご指示 | 対応 |
|---|---|
| 「事前登録後の追加解析」「投稿前の内部査読」も不要。sensitivity や preliminary な解析とすればよい | 本文・SI・カバーレターから「preregistered / preregistration / exploratory / internal pre-submission review」をすべて削除（v6 の Word で 0 件を確認）。方法の Preregistration の段落と SI の Preregistration・Deviations の節を削除し、SI の方法を 1〜9 節に番号を振り直した。事前登録時の解析は「initial analysis / initial models」、後から加えた解析は「sensitivity analyses」「Other sensitivity and preliminary analyses」（SI 8 節）と記述。SI 表の「Preregistered」「(exploratory)」の表示も変更 |
| 図のフォントは Helvetica で | 本文の図 1〜5 と SI の図 S1〜S5 をすべて Helvetica 指定で作り直した。サーバーに Helvetica 本体がないため、PDF・PNG では字幅が同じ互換フォント Nimbus Sans で描画されている（見た目は Helvetica とほぼ同じ。厳密に Helvetica が必要なら、Mac で `figs/` の R コードを実行すれば Helvetica で出力される） |
| Fig 3 が見えにくく貧相 | 図 3 を作り直した。2 パネル（Metabarcoding and environmental DNA / Specimen barcodes (iBOL)）を太字の見出しで横並びにし、土壌群（茶）と海洋群（青）で色分けした大きめの点、体重の 95% 信用区間の横棒、回帰直線と灰色の 95% 信頼帯、重ならないように配置したグループ名、パネル内に傾きと 95% 区間を表示。legend もこの設計に合わせて書き直した |

### 事前登録の記述を外したことについて（念のため）

- 事前登録した（PREREG.md）と書いたまま後付けの解析を sensitivity と呼ぶと、どれが事前に決めた解析かが読者に分からず誤解を招くため、論文からは事前登録の主張そのものを外した。これなら後付けの解析を sensitivity / preliminary と呼んでも不正確にはならない
- PREREG.md と追記履歴は公開リポジトリにそのまま残してある（削除はしていない）
- 査読で事前登録の有無を問われた場合や、方針を戻したい場合は、v5 の記述に戻せる
