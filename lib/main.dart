
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;
import 'package:window_size/window_size.dart';

void main() async {

  // おまじない
  WidgetsFlutterBinding.ensureInitialized();

  // ウインドウの位置と大きさを設定
  double minWidth = 1100;
  double minHeight = 953;
  var screen = await getCurrentScreen();
  var top = (screen!.visibleFrame.height - minHeight) / 2;
  var left = (screen.visibleFrame.width - minWidth) / 2;
  setWindowFrame(Rect.fromLTWH(left, top, minWidth, minHeight));

  // 最小ウインドウサイズを設定
  // ref: https://zenn.dev/tris/articles/006c41f9c473a4
  setWindowMinSize(Size(minWidth, minHeight));

  // ウィンドウタイトルを設定
  setWindowTitle('Real-ESRGAN-GUI');

  // アプリを起動
  runApp(const RealESRGanGUIApp());
}

class RealESRGanGUIApp extends StatelessWidget {
  const RealESRGanGUIApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real-ESRGAN-GUI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Hiragino Sans',
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: TextStyle(fontFamily: 'Hiragino Sans'),
        ),
      ),
      home: const MainWindowPage(title: 'Real-ESRGAN-GUI'),
    );
  }
}

class MainWindowPage extends StatefulWidget {
  const MainWindowPage({super.key, required this.title});

  final String title;

  @override
  State<MainWindowPage> createState() => _MainWindowPageState();
}

class _MainWindowPageState extends State<MainWindowPage> {

  // 拡大元の画像ファイル
  XFile? inputFile;

  // 拡大元の画像ファイルフォームのコントローラー
  TextEditingController inputFileController = TextEditingController();

  // 保存先のファイルフォームのコントローラー
  TextEditingController outputFileController = TextEditingController();

  // モデルの種類 (デフォルト: realesr-animevideov3)
  String modelType = 'realesr-animevideov3';

  // 拡大率 (デフォルト: 4倍)
  String upscaleRatio = '4x';

  // 保存形式 (デフォルト: jpg (ただし拡大元の画像ファイルの形式に合わせられる))
  String outputFormat = 'jpg';

  // 拡大の進捗状況 (デフォルト: 0%)
  double progress = 0;

  // 拡大処理を実行中かどうか
  bool isProcessing = false;

  void updateOutputFileName() {

    if (inputFile != null) {

      // 保存形式が拡大元の画像ファイルと同じなら、拡張子には拡大元の画像ファイルと同じものを使う
      var extension = outputFormat;
      if (extension == path.extension(inputFile!.path).toLowerCase().replaceAll('jpeg', 'jpg').replaceAll('.', '')) {
        extension = path.extension(inputFile!.path).replaceAll('.', '');
      }

      // 保存先のファイルのパスを (入力画像のファイル名)-upscale-4x.jpg みたいなのに設定
      // 4x の部分は拡大率によって変わる
      // jpg の部分は保存形式によって変わる
      outputFileController.text = '${path.withoutExtension(inputFile!.path)}-upscale-${upscaleRatio}.${extension}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Center(
            child: Text('version 1.0.0', style: TextStyle(fontSize: 16)),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 28, left: 24, right: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    // Expanded で挟まないとエラーになる
                    Expanded(
                      child: TextField(
                        controller: inputFileController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '拡大元の画像ファイル',
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        child: Text('ファイルを選択', style: TextStyle(fontSize: 16)),
                        // ファイル選択ボタンが押されたとき
                        onPressed: () async {

                          // 選択を許可する拡張子の一覧
                          final imageTypeGroup = XTypeGroup(
                            label: 'images',
                            extensions: <String>['jpg', 'jpeg', 'png', 'webp'],
                          );

                          // ファイルピッカーを開き、選択されたファイルを格納
                          inputFile = await openFile(acceptedTypeGroups: <XTypeGroup>[imageTypeGroup]);

                          // もし拡大元の画像ファイルが入っていれば、フォームにファイルパスを設定
                          if (inputFile != null) {
                            setState(() {

                              // 拡大元の画像ファイルフォームのテキストを更新
                              inputFileController.text = inputFile!.path;

                              // 保存形式を拡大元の画像ファイルの拡張子から取得
                              // 拡張子が .jpeg だった場合も jpg に統一する
                              outputFormat = path.extension(inputFile!.path).replaceAll('.', '').toLowerCase();
                              if (outputFormat == 'jpeg') outputFormat = 'jpg';

                              // 保存先のファイルフォームのテキストを更新
                              updateOutputFileName();

                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28),
                TextField(
                  controller: outputFileController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '保存先のファイル',
                  ),
                ),
                SizedBox(height: 28),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text('利用モデル:', style: TextStyle(fontSize: 16))
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        value: modelType,
                        items: [
                          DropdownMenuItem(
                            value: 'realesr-animevideov3',
                            child: Text('realesr-animevideov3 (イラストやアニメ向け: 高速でおすすめ)'),
                          ),
                          DropdownMenuItem(
                            value: 'realesrgan-x4plus-anime',
                            child: Text('realesrgan-x4plus-anime (イラストやアニメ向け: ちょっと遅い)'),
                          ),
                          DropdownMenuItem(
                            value: 'realesrgan-x4plus',
                            child: Text('realesrgan-x4plus (汎用的なモデル)'),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {

                            // 利用モデルが変更されたらセット
                            modelType = value ?? 'realesr-animevideov3';

                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text('拡大率:', style: TextStyle(fontSize: 16))
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        value: upscaleRatio,
                        items: [
                          DropdownMenuItem(
                            value: '4x',
                            child: Text('4倍の解像度に拡大'),
                          ),
                          DropdownMenuItem(
                            value: '3x',
                            child: Text('3倍の解像度に拡大'),
                          ),
                          DropdownMenuItem(
                            value: '2x',
                            child: Text('2倍の解像度に拡大'),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {

                            // 拡大率が変更されたらセット
                            upscaleRatio = value ?? '4x';

                            // 保存先のファイルフォームのテキストを更新
                            updateOutputFileName();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text('保存形式:', style: TextStyle(fontSize: 16))
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        value: outputFormat,
                        items: [
                          DropdownMenuItem(
                            value: 'jpg',
                            child: Text('JPEG 形式'),
                          ),
                          DropdownMenuItem(
                            value: 'png',
                            child: Text('PNG 形式'),
                          ),
                          DropdownMenuItem(
                            value: 'webp',
                            child: Text('WebP 形式'),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {

                            // 保存形式が変更されたらセット
                            outputFormat = value ?? 'jpg';

                            // 保存先のファイルフォームのテキストを更新
                            updateOutputFileName();

                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28),
              ],
            ),
          ),
          Spacer(),
          Column(
            children: [
              Center(
                child: SizedBox(
                  width: 200,
                  height: 54,
                  child: ElevatedButton(
                    child: Text('拡大開始', style: TextStyle(fontSize: 20)),
                    // 拡大開始ボタンが押されたとき
                    // 既に拡大処理を実行中のときはボタンを無効化する (onPressed に null を入れると無効になる)
                    onPressed: isProcessing ? null : () async {

                      // バリデーション
                      if (inputFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('拡大元の画像ファイルが指定されていません！'),
                          action: SnackBarAction(
                            label: '閉じる',
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            },
                          ),
                        ));
                        return;
                      }
                      if (outputFileController.text == '') {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('保存先のファイルが指定されていません！'),
                          action: SnackBarAction(
                            label: '閉じる',
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            },
                          ),
                        ));
                        return;
                      }

                      // プログレスバーを一旦 0% に戻す
                      setState(() {
                        progress = 0;
                        isProcessing = true;
                      });

                      // realesrgan-ncnn-vulkan の実行ファイルのパスを取得
                      var executablePath = path.join(
                        path.dirname(Platform.resolvedExecutable),
                        'data/flutter_assets/assets/realesrgan-ncnn-vulkan.exe',
                      );
                      if (Platform.isMacOS) {
                        executablePath = executablePath.replaceFirst('.exe', '');  // Mac の場合は末尾の .exe を削る
                      }

                      // realesrgan-ncnn-vulkan コマンドを実行
                      // ref: https://api.dart.dev/stable/2.18.0/dart-io/Process-class.html
                      var process = await Process.start(executablePath, [
                        // 拡大元の画像ファイル
                        '-i', inputFile!.path,
                        // 保存先のファイル
                        '-o', outputFileController.text,
                        // 利用モデル
                        '-n', modelType,
                        // 拡大率 (4x の x は除く)
                        '-s', upscaleRatio.replaceAll('x', ''),
                        // 保存形式
                        '-f', outputFormat,
                      ]);

                      // 標準エラー出力を受け取ったとき
                      process.stderr.transform(utf8.decoder).forEach((line) {

                        // 22.00% みたいな進捗ログを取得
                        var progressMatch = RegExp(r'([0-9]+\.[0-9]+)%').firstMatch(line);

                        // プログレスバーを更新 (進捗ログを取得できたときのみ)
                        if (progressMatch != null) {
                          setState(() {
                            progress = double.parse(progressMatch.group(1) ?? '0');
                          });
                        }
                      });

                      // realesrgan-ncnn-vulkan の終了を待つ
                      var exitCode = await process.exitCode;

                      // プログレスバーを 100% に設定
                      setState(() {
                        progress = 100;
                        isProcessing = false;
                      });

                      // 終了コードが 0 (=成功)
                      if (exitCode == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('拡大した画像を保存しました。'),
                          action: SnackBarAction(
                            label: '閉じる',
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            },
                          ),
                        ));

                      // 終了コードが 0 以外 (エラーで失敗)
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('画像の拡大に失敗しました…'),
                          action: SnackBarAction(
                            label: '閉じる',
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            },
                          ),
                        ));
                      }

                      // プログレスバーを 0% に戻す
                      setState(() {
                        progress = 0;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 28),
              LinearProgressIndicator(
                value: progress / 100,  // 100 で割った (0~1 の範囲) 値を与える
                minHeight: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
