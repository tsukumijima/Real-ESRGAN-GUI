
# Real-ESRGAN-GUI

<img width="600" src="https://user-images.githubusercontent.com/39271166/189376465-845ecfc0-3d08-4da3-8632-b2ed7ea9b6d9.png">

-----

[Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN) の NCNN (Vulkan) 実装である、[realesrgan-ncnn-vulkan](https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan) という CLI ツールのかんたんな GUI ラッパーです。

[Flutter on Desktop](https://flutter.dev/multi-platform/desktop) を使って突貫で合計5～6時間くらいで作りました。  
かんたんにきれいな UI で作れる [Flutter](https://flutter.dev/) 最高！

## インストール

### Windows

Windows 10 以降の 64bit OS にのみ対応しています。Windows 8 以前と、32bit OS は対応していません。

GPU には [realesrgan-ncnn-vulkan](https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan) 同様に、Intel Graphics・NVIDIA GPU・AMD GPU が利用できます。 

<img width="600" src="https://user-images.githubusercontent.com/39271166/189310933-c0767313-faf7-417e-aed1-b6196c367379.png">

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

たぶん説明するまでもないと思いますが…。

利用モデルは `realesr-animevideov3` が一番高速で、精度も高いです（おすすめ）。  
`realesrgan-x4plus-anime` よりもエッジ（解像感）は控えめですが、元の画像のディティールを比較的保ったままきれいにノイズが消え、自然な仕上がりになります。  

`realesrgan-x4plus-anime` は、`realesr-animevideov3` での出来栄えに満足できなかったときに試してみると良さそうです。  
より解像感のある仕上がりになりますが、その分 `realesr-animevideov3` よりも細かい塗りなどのディティールが失われがちに見えます（とはいえ、比較しなければ違いがわからないレベルだとは思います）。

`realesrgan-x4plus` は、いろいろな画像に使えるモデルです。ただ、Intel UHD Graphics 620 の環境だと結構重めです（数分掛かった…）。  
なお、同じ画像、同じ `realesrgan-x4plus` を使った場合でも、NVIDIA GPU が搭載されている環境では数秒で拡大画像の生成が完了しました。  
汎用的なモデルなので実写にもアニメにも使えますが、アニメの場合は `realesrgan-x4plus-anime` の方がよりアニメらしい画になる印象です。

## トラブルシューティング

### 「MSVCP140.dll が見つからないため、コードの実行を継続できません」というエラーが表示されて起動できない

[Visual C++ 再頒布可能パッケージ 2015-2022](https://docs.microsoft.com/ja-jp/cpp/windows/latest-supported-vc-redist?view=msvc-170) のインストールが必要です。  
[vc_redist.x64.exe](https://aka.ms/vs/17/release/vc_redist.x64.exe) をダウンロード後、ダウンロードした `vc_redist.x64.exe` をダブルクリックしてインストールしてください。

インストール後にもう一度 `Real-ESRGAN-GUI.exe` をダブルクリックすると、ちゃんと起動できるはずです。

### 拡大率を [2倍の解像度に拡大] [3倍の解像度に拡大] に設定すると、生成された画像が壊滅する

おそらくバックエンドで利用している [realesrgan-ncnn-vulkan](https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan) のバグ or 仕様です。こちらではどうしようもありません…。  
なお、ちゃんと2倍の解像度に拡大できることもあります。フル HD などの元々解像度が高い画像を Real-ESRGAN に掛けると起こりやすい印象です。

元々4倍に拡大することを前提に開発されているようなので、うまくいかないときは [4倍の解像度に拡大] に設定してから、適宜画像編集ソフトなどでリサイズしてみてください。

### 「画像の拡大に失敗しました」というエラーで画像の拡大ができない

原因は様々ななので一概にはいえませんが、まず保存先のファイルパスが誤っている（フォルダが存在しない、パス指定が不正、など）可能性があると思います。

また、GPU のドライバーのバージョンが古くなっていると、画像を生成できなかったり、生成したとしても真っ黒の画像しか生成されないなどの問題が生じることがあるようです。  
一度 GPU のドライバーを最新バージョンのものに更新してみることをおすすめします。

## License

[MIT License](License.txt)
