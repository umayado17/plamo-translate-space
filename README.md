# plamo-translate-space

Muse のスペースに、翻訳特化の国産モデル **PLaMo 3 Translate 0.8B** を Muse VM の中でローカル実行する翻訳アプリを組み立てるための SKILL（レシピ）です。

原文は VM の外に出ません。外部の翻訳 API やクラウド LLM は使いません。GPU のない VM（CPU 4コア）でも、1文およそ1.5秒で訳せます（2026-11-08 実測）。

## なぜ「レシピ」なのか

裏側にプログラムやデータを持つ動的なスペースは、公開リンクでは共有できません。実行場所とデータが、持ち主の VM に結び付いているためです。

代わりに共有できるのが、この作り方です。受け取った人の Muse が、その人自身の VM・その人の環境の中で、同じスペースを組み直します。実体のコピーではなく、材料・組み立て順・仕様・合格基準の共有です。

## 使い方

1. このリポジトリを自分の Muse に渡す（クローン、または Release の zip）
2. 一言いう：「SKILL.md の手順で、私の Muse に PLaMo翻訳スペースを作って」
3. Muse 側が、モデル取得 → ローカルサーバー起動 → 試訳での検証 → スペース作成 → スペース経由の検証、までを行います

## 中身

- `SKILL.md` ― 手順の本体（段1〜4と検証ゲート）
- `references/space-spec.md` ― スペース作成時にそのまま使う仕様文
- `scripts/setup-and-start.sh` ― モデルと llama.cpp の取得、サーバー起動、応答確認まで一括

## 前提

- Muse の VM が Linux x64、CPU 4コア程度、ディスク空き 2GB 以上
- モデルは Hugging Face で公開されている `pfnet/plamo-3-translate-0.8b-GGUF`（Q4_K_M、547MB）を実行時に取得します（このリポジトリには含みません）
- モデルのライセンスは PLaMo Community License です。個人の私的利用は事前登録不要、商用利用は条件が別途あります

## English summary

A skill (recipe) for building a translation Space in Muse that runs
Preferred Networks' open-weight PLaMo 3 Translate 0.8B model locally inside
the Muse VM via llama.cpp. Dynamic Muse Spaces cannot be shared by public
link, so this repository shares the rebuildable recipe instead: materials,
build order, the Space specification, and fixed acceptance tests. Verified
end-to-end on 2026-11-08.

## License

MIT (this recipe and scripts). The PLaMo 3 Translate model weights are
distributed by Preferred Networks under the PLaMo Community License and are
not included in this repository.
