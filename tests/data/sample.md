# KeyEvent Laboratory

これは keyevent.nvim と rush.nvim の動作を確認するためのテスト用 Markdown 文書です。
日本語、English、数字、記号、Markdown 構文を意図的に混在させています。

## 01. はじめに

キーボードから入力された文字は、単純な一文字ではなく、時間の流れを持ったイベントとして観察できます。
たとえば `j` を一度押す場合と、`j` を押し続ける場合では、同じキーでも異なるイベント列になります。
`click`、`tap`、`repeat`、そしてキーを離した瞬間を観察すると、入力の時間的な構造が見えてきます。

ここでは特定の文章を読むことよりも、カーソルを自由に動かして、キー入力の挙動を眺めることを目的とします。

## 02. 短い行

a
ab
abc
abcd
日本
日本語
テスト
ABC
ABC123
1234567890
!
!!
???
---

---

短い行の次には、普通の長さの行を置きます。

## 03. 普通の文章

春の朝、窓を開けると静かな風が部屋の中へ入ってきました。机の上には古いノートと新しいキーボードが並んでいます。
プログラムを書いていると、画面上の小さなカーソルが意外なほど重要な存在であることに気づきます。

日本語の文章では、漢字、ひらがな、カタカナが自然に混ざります。
English words may appear in the middle of a Japanese sentence, and numbers such as 2026 or 3.141592653589793 may appear as well.

キー操作のテストでは、`h`、`j`、`k`、`l` を何度も入力します。
さらに `w`、`b`、`e`、`ge` のような単語移動も試します。

## 04. 記号

ASCII 記号をまとめて並べます。

```text
! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
```

日本語の記号も確認します。

```text
「こんにちは」『テスト文章』【重要】（補足）［配列］〈項目〉《引用》〔注記〕
```

似ている文字でも Unicode 上では別の文字です。

```text
() （） [] ［］ {} ｛｝ <> ＜＞ -- ー ― ～ ~
```

## 05. Markdown

Markdown の強調記法を確認します。

**太字の日本語**、*斜体の日本語*、`inline code`、~~取り消し線~~。
リンク風の文字列は [example](https://example.com/test?q=123&lang=ja) と書けます。

> これは引用文です。カーソルを行頭から行末まで何度も往復させてみてください。

* 最初の項目
* 二番目の項目

  * 内側の項目
  * もう一つの項目
* 最後の項目

1. 一番目
2. 二番目
3. 三番目

## 06. 数字と英字

数字を連続させます。

```text
0123456789 1234567890 9876543210 314159265358979323846264338327950288419716939937510
```

英字も連続させます。

```text
abcdefghijklmnopqrstuvwxyz
ABCDEFGHIJKLMNOPQRSTUVWXYZ
Aa Bb Cc Dd Ee Ff Gg Hh Ii Jj Kk Ll Mm Nn Oo Pp Qq Rr Ss Tt Uu Vv Ww Xx Yy Zz
```

識別子らしい文字列もあります。

```text
keyevent.nvim
rush.nvim
vim.v.count
vim.keymap.set
nvim_buf_get_lines
on_key
repeat_end
```

## 07. CJK と ASCII の混在

日本語ABC日本語123日本語xyz日本語---日本語+++日本語===日本語___日本語。
Hello世界、world世界、Neovim日本語、Luaコード、GitHubリポジトリ、OSS開発。
`日本語` と `English` と `12345` と `!@#$%` を同じ行に置いてみます。

「ABC」「日本語」「123」「!@#」「foo_bar」「foo-bar」「foo/bar」「foo.bar」を比較します。

## 08. URL とパス

URL は長くなることがあります。

https://example.com/path/to/document?id=12345&lang=ja&mode=test#section-04

ファイルパスもあります。

```text
~/oss/keyevent.nvim/lua/keyevent/keyevent.lua
~/.config/nvim/lua/custom/plugins/rush.lua
/usr/local/bin/nvim
/Users/example/Documents/project/test-data.md
```

Windows 風のパスも置きます。

```text
C:\Users\example\Documents\project\test.md
D:\work\keyevent\data\sample.txt
```

## 09. 長い行

この行は横方向のカーソル移動を試すために意図的に長くしています。日本語の文字列と English words、1234567890、記号 !@#$%^&*()_+-=[]{};:',.<>/?|、Markdown の **bold** や *italic*、`inline code`、URL https://example.com/path/to/resource?q=123&lang=ja#section などを混在させています。さらに「日本語の括弧（全角）」「半角括弧 (ASCII)」「［全角角括弧］ [ASCII brackets]」「【隅付き括弧】」「<tag attr="value">」「key=value」「foo->bar」「a::b::c」といったパターンも含め、横方向に長く連続させています。

この文章は rush.nvim の h/l による移動を試すためのものです。カーソルを行頭に置いてから l を長押しし、行末付近まで移動してみます。その後 h を長押しして逆方向へ戻ります。日本語と ASCII の幅が異なるため、表示上の位置と内部的な文字位置について考えるきっかけにもなります。さらに w や b を使えば、単純な一文字単位とは違う移動の様子も確認できます。

## 10. さらに長い行

keyevent.nvim はキー入力を時間情報とともに扱いますが、テストデータそのものには時間情報がありません。そのため、このような長い行を用意しておくと、実際のキーボード操作で click、tap、repeat が発生したときに、カーソルがどの位置まで進んだのかを目視で確認できます。たとえば `8j` の後に j を押し続ける操作、`6l` の後に l を押し続ける操作、あるいは w と b を交互に押す操作などを組み合わせると、通常の Neovim の移動と rush.nvim による加速の違いを確認しやすくなります。

## 11. 表

| key | event  | meaning            | example  |
| --- | ------ | ------------------ | -------- |
| `j` | click  | normal motion      | 下へ移動 |
| `j` | repeat | accelerated motion | 長押し   |
| `k` | repeat | reverse motion     | 上へ移動 |
| `w` | tap    | word motion        | 次の単語 |
| `b` | tap    | backward motion    | 前の単語 |
| `l` | repeat | horizontal motion  | 右へ移動 |

表の中にも日本語と ASCII を混ぜています。

## 12. コードブロック

```lua
local KeyEvent = require("keyevent")

local count = 8
local direction = "j"

print("count =", count)
print("direction =", direction)

for index = 1, count do
    print(index, direction)
end
```

コードの中には `local`、`function`、`return`、`end`、`if`、`then` などの短い単語が現れます。

## 13. 記号の密集

```text
foo(bar[baz{qux<xyz>}])!
foo(bar[baz{qux<xyz>}])?
foo::bar::baz->qux=>xyz
a==b && c!=d || e<=f && g>=h
x[0] = y[1] + z[2] * 3 / 4
```

記号が密集した場所では、`w` や `e` の動作も試してみます。

## 14. 日本語の句読点

日本語にはさまざまな句読点があります。
「これは引用です。」（これは括弧です。）【これは別の括弧です】［こちらも括弧です］〈さらに別の括弧〉。
文章の途中に……三点リーダがあります。――ダッシュもあります。〜波線もあります。

句読点の直後に英単語を置きます。たとえば、Neovim、Lua、Git、GitHub、Markdown などです。

## 15. 数値

整数: 0, 1, 2, 3, 10, 100, 1000
負数: -1, -2, -100
小数: 0.1, 1.5, 3.141592653589793
指数: 1e3, 2.5e-4
16進数: 0x00, 0x10, 0xff, 0x12345678

大きな整数もあります。

```text
12345678901234567890123456789012345678901234567890
```

## 16. 短い行と長い行

ここからは行長を意図的に変化させます。

短い。

少し長い行です。

もう少し長い行です。日本語と English を混ぜます。

これはさらに長い行です。カーソルを左右に移動させて、画面端付近でスクロールがどのように発生するかを確認してください。1234567890 !@#$% `code` **bold** [link](https://example.com)。

## 17. 箇条書きの深さ

* level 1

  * level 2

    * level 3

      * level 4

        * level 5
* 日本語の level 1

  * 日本語の level 2

    * 日本語の level 3

## 18. 空行

上の節とこの節の間には、複数の空行があります。

空行を越えてカーソルを移動するときの動作も確認できます。

## 19. 混在した文章

あるところでは日本語だけを書き、別のところでは English only の文章を書き、その間に 12345 や記号 !@#$% を挿入します。すると、カーソルは文字種の境界を何度も通過することになります。たとえば `日本語ABC123` のような短い文字列から始めて、`日本語---ABC---123---xyz---!@#$%` のような文字列へ進み、最後には URL やファイルパスまで続けることができます。

## 20. テストシナリオ

まずカーソルをこの行の先頭へ移動します。
次に `l` を一回ずつ入力します。
続いて `l` を押し続けます。
その後 `h` を押し続けて元の位置へ戻ります。

次に `j` を押します。
そのまま `j` を連続して入力します。
最後に `k` を連続して入力して戻ります。

## 21. 特殊な文字列

```text
aaaaabbbbbcccccdddddeeeee
jjjjjkkkkklllllhhhhh
wwwwwbbbbbeeeeegegege
-----=====+++++*****
.....,,,,,;;;;;:::::
```

日本語でも同じような繰り返しを置きます。

```text
あああああいいいいいううううう
漢漢漢漢漢字字字字字
テテテテテストストスト
```

## 22. Markdown の境界

**bold** の直前と直後、`code` の前後、[link](https://example.com) の前後には記号があります。
たとえば `foo**bold**bar`、`foo`code`bar`、`foo[link](https://example.com)bar` のような文字列です。

## 23. コメント風文字列

```text
# heading
// comment
/* comment */
-- lua comment
<!-- html comment -->
```

これらはすべて単なるテストデータです。

## 24. 500文字近いテスト行

最後に非常に長い行を置きます。この行では、日本語、English、数字、記号、Markdown、URL、ファイルパス、括弧、引用符、演算子などを一つの行にまとめています。日本語の文章を書きながら `keyevent.nvim` と `rush.nvim` の名前を何度も登場させ、さらに `h j k l w b e ge`、`<C-R>`、`<Esc>`、`<A-j>`、`vim.v.count`、`vim.keymap.set()` といった文字列を追加します。数字は 0123456789、16進数は 0x123456789abcdef、記号は !@#$%^&*()_+-=[]{};:'",.<>/?|~ を使用します。URL は https://example.com/a/b/c?q=123&lang=ja#test、パスは ~/oss/keyevent.nvim/lua/keyevent/keyevent.lua、括弧は （日本語）(ASCII)［日本語］[ASCII]【日本語】{ASCII}、引用符は「日本語」"English" 'single' `code` とします。さらに ABCDEFGHIJKLMNOPQRSTUVWXYZ と abcdefghijklmnopqrstuvwxyz を加え、最後に 日本語ABC123xyz!@#$% を置きます。このように異なる文字種を連続して配置すると、カーソル移動、スクロール、単語移動、キーリピートによる加速などを一つの行でまとめて観察できます。

## 25. 終了

ここまでがテストデータです。

最後の確認として、`h`、`j`、`k`、`l`、`w`、`b`、`e`、`ge` を自由に組み合わせてカーソルを動かしてください。

長い行では横方向の移動を、短い行では行間の移動を、コードブロックでは記号を、通常の文章では日本語と ASCII の混在を確認できます。

keyevent.nvim のイベント表示と rush.nvim の加速動作が、この文書を使って観察できればテスト成功です。
