
# Real-ESRGAN-GUI

<img width="600" src="https://user-images.githubusercontent.com/39271166/192086070-aedde748-588f-456a-9c88-6fb77877b293.png">

-----

[Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN) の NCNN (Vulkan) 実装である、[realesrgan-ncnn-vulkan](https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan) という CLI ツールのかんたんな GUI ラッパーです。  
v1.2.0 からは [Real-CUGAN](https://github.com/bilibili/ailab/tree/main/Real-CUGAN) の NCNN (Vulkan) 実装である [realcugan-ncnn-vulkan](https://github.com/nihui/realcugan-ncnn-vulkan) の GUI ラッパー機能も統合しています。  
低解像度・低画質なイラストやアニメなどの画像を、くっきりきれいに拡大（高画質化）することができます。

[Flutter on Desktop](https://flutter.dev/multi-platform/desktop) を使って突貫で合計5～6時間くらいで作りました (v1.0.0) 。  
かんたんにきれいな UI で作れる [Flutter](https://flutter.dev/) 最高！

## インストール

### Windows

Windows 10 以降の 64bit OS にのみ対応しています。Windows 8 以前と、32bit OS は対応していません。

GPU には [realesrgan-ncnn-vulkan](https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan) / [realcugan-ncnn-vulkan](https://github.com/nihui/realcugan-ncnn-vulkan) 同様に、Intel Graphics・NVIDIA GPU・AMD GPU が利用できます。 

<img width="600" src="https://user-images.githubusercontent.com/39271166/192085275-01e56bc9-4ca8-4e90-b9b9-5092fb9e497b.png">

[Releases](https://github.com/tsukumijima/Real-ESRGAN-GUI/releases) ページから、最新の Real-ESRGAN-GUI をダウンロードします。  
`Real-ESRGAN-GUI-(バージョン)-windows.zip` をダウンロードしてください。

ダウンロードが終わったら `Real-ESRGAN-GUI-(バージョン)-windows.zip` を適当なフォルダに解凍し、中の `Real-ESRGAN-GUI.exe` をダブルクリックします。  
適宜ショートカットをデスクトップに作成してみても良いでしょう。

### macOS

Intel Mac と Apple Silicon (M1, M1 Pro, M2 ...etc) の両方に対応しています。  
Intel Mac よりも、Apple Silicon 搭載 Mac の方が画像の生成が速い印象です (Intel Mac でも最上級グレードの機種ならまた違うのかも)。

<img width="600" src="https://user-images.githubusercontent.com/39271166/189374416-15501eeb-41ba-452c-bef3-402dc450f31d.png">

[Releases](https://github.com/tsukumijima/Real-ESRGAN-GUI/releases) ページから、最新の Real-ESRGAN-GUI をダウンロードします。  
`Real-ESRGAN-GUI-(バージョン)-macos.zip` をダウンロードしてください。

ダウンロードが終わったら `Real-ESRGAN-GUI-(バージョン)-macos.zip` を解凍し、中の `Real-ESRGAN-GUI.app` をアプリケーションフォルダに移動します。  
その後、`Real-ESRGAN-GUI.app` をダブルクリックしてください。

## 使い方

1枚ごとにファイルを選択する [ファイル選択] と、フォルダ内にある複数の画像を一括で拡大する [フォルダ選択] の2つのモードがあります。

### Real-ESRGAN

<img width="600" src="https://user-images.githubusercontent.com/39271166/192085942-8efaeacd-256e-4359-88da-0e3e71caf2df.png">

どんな状態の画像でもそこそこいい感じに高画質にしてくれる、万能な AI 画像拡大アルゴリズムです。  
基本的にはイラストやアニメ向けですが、`realesrgan-x4plus` モデルを使えば実写の写真にも使えます。

Real-CUGAN と比べると線がシャープになったり色味がちょっと変わったり、細部のディティールが失われがちな傾向があります。  
とはいえ、AI 特有のアーティファクトがかなり少なく、見栄えの良い画になります。  
だいたいのケースで及第点を出してくれますし、線の色自体はきちんと保持してくれる印象です。

#### モデル

モデルは `realesr-animevideov3` が一番高速で、精度も高いです（おすすめ）。  
`realesrgan-x4plus-anime` よりもエッジ（解像感）は控えめですが、元の画像のディティールを比較的保ったままきれいにノイズが消え、自然な仕上がりになります。  
写真には `realesrgan-x4plus` の方が向いていますが、`realesr-animevideov3` でも（多少ディティールは失われるものの）それなりの出来にはなります。

`realesrgan-x4plus-anime` は、`realesr-animevideov3` での出来栄えに満足できなかったときに試してみると良さそうです。  
より解像感のある仕上がりになりますが、その分 `realesr-animevideov3` よりも細かい塗りなどのディティールが失われがちに見えます（とはいえ、比較しなければ違いがわからないレベルだとは思います）。

`realesrgan-x4plus` は、イラストやアニメだけでなく、いろいろな画像に使えるモデルです。ただ、Intel UHD Graphics 620 の環境だと結構重めです（数分掛かった…）。  
なお、同じ画像、同じ `realesrgan-x4plus` を使った場合でも、NVIDIA GPU が搭載されている環境では数秒で拡大画像の生成が完了しました。  
汎用的なモデルなので写真にもイラストにも使えますが、アニメの場合は `realesrgan-x4plus-anime` の方がよりアニメらしい画になります。

### Real-CUGAN

<img width="600" src="https://user-images.githubusercontent.com/39271166/192086045-2c265db2-d8e0-4785-8297-e7585af53d3b.png">

イラストやアニメに特化した AI 画像拡大アルゴリズムです。  
Real-ESRGAN の `realesr-animevideov3` よりも遅いですが、全体的に細部のディティールを保持した状態で画像を拡大できます。

ただし、アニメのキャプチャの場合、線の色が濃くなって `realesr-animevideov3` と比べてかなりシャープな画になりがちな印象があります。
それ以外の細部のディティールは確かに維持されているんですが、いかんせん「濃い」画になってしまうので、アニメなら `realesr-animevideov3` の方がより良い結果が得られると思います。  

（アニメ塗りではない）塗りにグラデーションを多用したイラストの場合は、細部のディティールやボケ感（シャープさ）が維持されるため、ディティールが潰れがちな Real-ESRGAN よりも良い結果が得られることが多いです。  
ただし、ディティールを保持する関係か、Real-ESRGAN よりもアーティファクト（画像の部分的な乱れ）が比較的発生しやすい印象はあります。無視できるレベルだとは思いますが…。

また、ノイズ除去レベルを指定できるのも特徴です。  
ノイズ除去レベルを最大に設定すると、ディティールが若干潰れるかわりに、JPEG ノイズを強力に除去することができます。  
なお、ノイズ除去レベルの 1 と 2 は、`models-se` モデルを指定したときだけ利用できます。

<img width="100%" src="https://user-images.githubusercontent.com/39271166/192088956-c386a241-4714-4a6d-9c78-b78faee8db8b.jpg">

本来は実写の写真の拡大にはまったく向いておらず、ノイズ除去なしの場合はいろいろ酷い画像になってしまいます。  
ところが、**あえて解像度を落とした写真を 600px 以下にリサイズした上で Real-CUGAN のノイズ除去レベルを 3 (最大) に設定して拡大すると、アニメの背景のようなディティールで出力されます。**  
さらに手動で色調補正を行えば、まるでアニメの背景のような画像になります（コントラストをかなり落とした上でハイライトとブラックを上げ、明瞭度を下げるのがポイント）。  
イラストの背景に使ったりなど、これはこれで別の活用法があるかもしれません。

#### モデル

モデルは `models-pro` が一番精度が高くておすすめです。  
`models-se` は `models-pro` よりも古いモデルですが、その分拡大率とノイズ除去レベルのバリエーションが豊富です。

`models-nose` は2倍の拡大率にしか拡大できませんが、線のエッジが細くてシャープな独特な画になります。  
ただし、細部のディティールは失われがちです。

## トラブルシューティング

### 「MSVCP140.dll が見つからないため、コードの実行を継続できません」というエラーが表示されて起動できない

[Visual C++ 再頒布可能パッケージ 2015-2022](https://docs.microsoft.com/ja-jp/cpp/windows/latest-supported-vc-redist?view=msvc-170) のインストールが必要です。  
[vc_redist.x64.exe](https://aka.ms/vs/17/release/vc_redist.x64.exe) をダウンロード後、ダウンロードした `vc_redist.x64.exe` をダブルクリックしてインストールしてください。

インストール後にもう一度 `Real-ESRGAN-GUI.exe` をダブルクリックすると、ちゃんと起動できるはずです。

### 拡大率を [2倍の解像度に拡大] [3倍の解像度に拡大] に設定すると、生成された画像が壊滅する

おそらくバックエンドで利用している [realesrgan-ncnn-vulkan](https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan) のバグ or 仕様です。こちらではどうしようもありません…。  
なお、ちゃんと2倍の解像度に拡大できることもあります。フル HD などの元々解像度が高い画像を Real-ESRGAN に掛けると起こりやすい印象です。

Real-ESRGAN は元々4倍に拡大することを前提に開発されているようなので、うまくいかないときは [4倍の解像度に拡大] に設定してから、適宜画像編集ソフトなどでリサイズしてみてください。

### 「画像の拡大に失敗しました」というエラーで画像の拡大ができない

原因は様々なので一概にはいえませんが、まず保存先のファイルパスが誤っている（フォルダが存在しない、パス指定が不正、など）可能性があると思います。

また、GPU のドライバーのバージョンが古くなっていると、画像を生成できなかったり、生成したとしても真っ黒の画像しか生成されないなどの問題が生じることがあるようです。  
一度 GPU のドライバーを最新バージョンのものに更新してみることをおすすめします。

## 寄付・支援について

**今のところ [アマギフ (Amazon ギフト券)](https://www.amazon.co.jp/b?node=3131877051&tag=tsukumijima-22) だけ受けつけています。**  

特典などは今のところありませんが、それでも寄付していただけるのであれば、アマギフの URL を [Twitter の DM (クリックすると DM が開きます)](https://twitter.com/messages/compose?recipient_id=1116800514614628352) か `tsukumizimaあっとgmail.com` まで送っていただけると、大変開発の励みになります…🙏🙏🙏

また、**[Amazon のほしい物リスト](https://www.amazon.co.jp/hz/wishlist/ls/3AZ4RI13SW2PV) もあります。** どのようなものでも贈っていただけると泣いて喜びます……😭🙏

このほか、**[こちら](https://www.amazon.co.jp/?tag=tsukumijima-22) のリンクをクリックしてから Amazon で何かお買い物していただくことでも支援できます (Amazon アソシエイト)。**  
買う商品はどのようなものでも OK ですが、より [紹介料率 (商品価格のうち、何%がアソシエイト参加者に入るかの割合)](https://affiliate.amazon.co.jp/help/node/topic/GRXPHT8U84RAYDXZ) が高く、価格が高い商品の方が、私に入る報酬は高くなります。Kindle の電子書籍や食べ物・飲み物は紹介料率が高めに設定されているみたいです。  

> もしかすると GitHub から Amazon に飛ぶと[リファラ](https://wa3.i-3-i.info/word129.html)チェックで弾かれてしまうかもしれないので、リンクをコピペして新しく開いたタブに貼り付ける方が良いかもしれません。

## License

[MIT License](License.txt)
