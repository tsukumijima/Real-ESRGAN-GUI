
import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as path;
import 'package:real_esrgan_gui/components/upscale_ratio_dropdown.dart';
import 'package:window_size/window_size.dart';
import 'package:real_esrgan_gui/components/io_form.dart';
import 'package:real_esrgan_gui/components/model_type_dropdown.dart';
import 'package:real_esrgan_gui/components/output_format_dropdown.dart';
import 'package:real_esrgan_gui/components/start_button_and_progress_bar.dart';
import 'package:real_esrgan_gui/utils.dart';

/// バージョン
const String version = '1.1.0';

void main() async {

  // おまじない
  WidgetsFlutterBinding.ensureInitialized();

  // ローカライゼーションの初期化
  await EasyLocalization.ensureInitialized();

  // スクリーン情報を取得
  var screen = await getCurrentScreen();

  // スクリーンの DPI スケールを取得
  var dpiScale = screen!.scaleFactor;

  // macOS では DPI スケールに関わらず常に1倍で表示する
  // Windows と DPI スケール周りの扱いが違うのかも…？ 1倍でちょうど良いサイズになる
  if (Platform.isMacOS) {
    dpiScale = 1;
  }

  // ウインドウの最小サイズ
  // DPI スケールに合わせて調整する (Windows のみ)
  /// macOS のみ、ウインドウの最小高さから 10px ほど引く
  /// Windows と macOS でウインドウのタイトルバーの高さが異なるため
  double minWidth = 750 * dpiScale;
  double minHeight = (Platform.isMacOS ? 636 : 646) * dpiScale;

  // 左上を起点にしたウインドウのX座標・Y座標
  double top = (screen.visibleFrame.height - minHeight) / 2;
  double left = (screen.visibleFrame.width - minWidth) / 2;

  // ウインドウの位置とサイズを設定
  setWindowFrame(Rect.fromLTWH(left, top, minWidth, minHeight));

  // 最小ウインドウサイズを設定
  // ref: https://zenn.dev/tris/articles/006c41f9c473a4
  setWindowMinSize(Size(minWidth, minHeight));

  // ウィンドウのタイトルを設定
  setWindowTitle('Real-ESRGAN-GUI');

  // ローカライゼーションを有効化した状態でアプリを起動
  runApp(EasyLocalization(
    path: 'assets/translations',
    supportedLocales: const [
      Locale('en', 'US'),
      Locale('ja', 'JP'),
      Locale('uk'),
    ],
    fallbackLocale: const Locale('en', 'US'),
    child: const RealESRGanGUIApp(),
  ));
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
        fontFamily: 'M PLUS 2',
        snackBarTheme: const SnackBarThemeData(
          contentTextStyle: TextStyle(fontFamily: 'M PLUS 2'),
        ),
      ),
      home: const MainWindowPage(title: 'Real-ESRGAN-GUI'),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}

class MainWindowPage extends StatefulWidget {
  const MainWindowPage({super.key, required this.title});

  final String title;

  @override
  State<MainWindowPage> createState() => MainWindowPageState();
}

class MainWindowPageState extends State<MainWindowPage> {

  // 入出力フォームのモード
  IOFormMode ioFormMode = IOFormMode.fileSelection;

  // ***** ファイル選択モード *****

  /// 拡大元の画像ファイルフォームのコントローラー
  TextEditingController inputFileController = TextEditingController();

  /// 保存先の画像ファイルフォームのコントローラー
  TextEditingController outputFileController = TextEditingController();

  // ***** フォルダ選択モード *****

  /// 拡大元の画像の入ったフォルダフォームのコントローラー
  TextEditingController inputFolderController = TextEditingController();

  /// 保存先のフォルダフォームのコントローラー
  TextEditingController outputFolderController = TextEditingController();

  // ***** 出力設定 *****

  /// モデルの種類 (デフォルト: realesr-animevideov3)
  /// "realesr-animevideov3"・"realesrgan-x4plus-anime"・"realesrgan-x4plus" のいずれか
  String modelType = 'realesr-animevideov3';

  /// 拡大率 (デフォルト: 4倍)
  /// "4x"・"3x"・"2x" のいずれか
  String upscaleRatio = '4x';

  /// 保存形式 (デフォルト: jpg (ただし既定で選択された拡大元画像の拡張子に変更される))
  /// "jpg"・"png"・"webp" のいずれか
  String outputFormat = 'jpg';

  // ***** プロセス実行関連 *****

  /// 拡大の進捗状況 (デフォルト: 0%)
  double progressPercentage = 0;

  /// 拡大処理を実行中かどうか
  bool isProcessing = false;

  /// コマンドの実行プロセス
  late Process process;

  /// 画像の拡大処理を開始する
  Future<void> upscaleImage() async {

    // 既に拡大処理を実行中のときは拡大処理をキャンセルする
    if (isProcessing == true) {
      process.kill();
      isProcessing = false;
      return;
    }

    // 入出力フォームのバリデーションを実行
    // false が返された場合はバリデーションに引っ掛かっているので、処理を中断
    var validateResult = await validateIOForm(
      context: context,
      ioFormMode: ioFormMode,
      inputFileController: inputFileController,
      outputFileController: outputFileController,
      inputFolderController: inputFolderController,
      outputFolderController: outputFolderController,
    );
    if (validateResult == false) return;

    // 処理対象の画像ファイルのパスのリスト
    List<Map<String, String>> imageFiles = [];

    // ファイル選択モードでは、選択されたファイル1つだけを追加する
    if (ioFormMode == IOFormMode.fileSelection) {

      // 入力元ファイルと出力先ファイルをセットで追加
      // 出力先ファイルにはフォームの値を使う
      imageFiles.add({'input': inputFileController.text, 'output': outputFileController.text});

      // 出力先ファイルが保存されるフォルダを作成 (すでにある場合は何もしない)
      await Directory(path.dirname(outputFileController.text)).create(recursive: true);

    // フォルダ選択モードでは、選択されたフォルダ以下の画像ファイル（1階層のみ）すべてを追加する
    } else if (ioFormMode == IOFormMode.folderSelection) {

      // 画像ファイルのみを Glob で取得
      var glob = Glob('{*.jpg,*.jpeg,*.png,*.webp}');
      for (var file in glob.listSync(root: inputFolderController.text)) {

        // 出力先ファイル名を生成
        var outputFilePath = path.join(
          // 出力先フォルダフォームの値
          outputFolderController.text,
          // 入力元ファイルの拡張子なしファイル名 + 保存形式 (jpg / png / webp)
          '${path.basenameWithoutExtension(file.path)}.${outputFormat}',
        );

        // 入力元ファイルと出力先ファイルをセットで追加
        imageFiles.add({'input': file.path, 'output': outputFilePath});
      }

      // この時点でひとつも画像ファイルが見つからなかった場合、エラーを出して終了
      if (imageFiles.isEmpty) {
        showSnackBar(context: context, content: const Text('message.noImageFilesInFolder').tr());
        return;
      }

      // 出力先フォルダを作成 (すでにある場合は何もしない)
      await Directory(outputFolderController.text).create(recursive: true);
    }

    // プログレスバーを一旦 0% に戻す
    setState(() {
      progressPercentage = 0;
      isProcessing = true;
    });

    // 画像ファイル1つごとに何%プログレスバーを進めるかの値
    // たとえば4つのファイルが処理対象なら、ここには 25 (%) が入る
    var progressStep = 100 / imageFiles.length;

    // 画像ファイルごとに繰り返す
    for (var progressIndex = 0; progressIndex < imageFiles.length; progressIndex++) {

      // realesrgan-ncnn-vulkan の実行ファイルのパスを取得
      var executablePath = getUpscaleAlgorithmExecutablePath(UpscaleAlgorithmType.RealESRGAN);

      // realesrgan-ncnn-vulkan コマンドを実行
      // ワーキングディレクトリを実行ファイルと同じフォルダに移動しておかないと macOS で Segmentation fault になり実行に失敗する
      // 実行ファイルと同じフォルダでないと models/ 以下の学習済みモデルが読み込めないのかも…？
      // ref: https://api.dart.dev/stable/2.18.0/dart-io/Process-class.html
      process = await Process.start(executablePath,
        [
          // 拡大元の画像ファイル
          '-i', imageFiles[progressIndex]['input']!,
          // 保存先の画像ファイル
          '-o', imageFiles[progressIndex]['output']!,
          // 利用モデル
          '-n', modelType,
          // 拡大率 (4x の x は除く)
          '-s', upscaleRatio.replaceAll('x', ''),
          // 保存形式
          '-f', outputFormat,
        ],
        workingDirectory: path.dirname(executablePath),
      );

      // 標準エラー出力を受け取ったとき
      List<String> lines = [];  // すべてのログを貯めるリスト
      process.stderr.transform(utf8.decoder).forEach((line) {

        // 22.00% みたいな進捗ログの取得を試みる
        var progressMatch = RegExp(r'([0-9]+\.[0-9]+)%').firstMatch(line);

        // プログレスバーを更新 (進捗ログを取得できたときのみ)
        if (progressMatch != null) {

          // 進捗ログを数値としてパースして格納
          var progressData = double.parse(progressMatch.group(1) ?? '0');

          setState(() {
            // 完了済みの画像の進捗 + 現在処理中の画像の進捗
            progressPercentage = (progressStep * (progressIndex)) + (progressData / imageFiles.length);
          });

        // 失敗したときにエラーログを表示するために受け取ったログを貯めておく
        } else {
          lines.add(line);
        }
      });

      // realesrgan-ncnn-vulkan の終了を待つ
      var exitCode = await process.exitCode;

      // プロセス終了のこの時点で isProcessing が false になっている場合、以降の処理がキャンセルされたものとして扱う
      var isCanceled = false;
      if (isProcessing == false) isCanceled = true;

      // プログレスバーを (progressStep × 完了済みの画像の個数) に設定
      setState(() {
        progressPercentage = progressStep * (progressIndex + 1);
      });

      // 終了コードが 0 以外 (エラーで失敗)
      if (exitCode != 0) {

        if (isCanceled) {

          // キャンセルの場合のメッセージ
          showSnackBar(context: context, content: const Text('message.canceled').tr());

        } else {

          // 実行ログを取得し、文字列として連結
          // もじ実行ログが空のときは、代わりに終了コードを入れる
          var log = lines.join('').trim();
          if (log == '') log = 'exit code: ${exitCode}';

          // エラーの場合のメッセージ
          showSnackBar(
            context: context,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('message.failed'.tr()),
                  SelectableText('message.errorLog'.tr(args: [log])),
                ],
              ),
            ),
            duration: const Duration(seconds: 10),  // 10秒間表示
          );
        }

        // プログレスバーを 0% に戻す
        setState(() {
          progressPercentage = 0;
          isProcessing = false;
        });

        // 実行を中断
        return;
      }
    }

    // 完了した旨を表示する
    showSnackBar(context: context, content: const Text('message.completed').tr());

    // プログレスバーを 0% に戻す
    setState(() {
      progressPercentage = 0;
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: const [
          Center(
            child: Text('version ${version}', style: TextStyle(fontSize: 16)),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4, left: 24, right: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IOFormWidget(
                  inputFileController: inputFileController,
                  outputFileController: outputFileController,
                  inputFolderController: inputFolderController,
                  outputFolderController: outputFolderController,
                  // Widget ビルド時点での拡大率 (setState() を実行すると新しいものが反映される)
                  upscaleRatio: upscaleRatio,
                  // Widget ビルド時点での保存形式 (setState() を実行すると新しいものが反映される)
                  outputFormat: outputFormat,
                  // タブが切り替えられたときのイベント
                  onModeChanged: (ioFormMode) => setState(() => this.ioFormMode = ioFormMode),
                  // 保存形式が（拡大元ファイルの選択により）変更されたときのイベント
                  onOutputFormatChanged: (outputFormat) => setState(() => this.outputFormat = outputFormat),
                ),
                const SizedBox(height: 20),
                ModelTypeDropdownWidget(
                  upscaleAlgorithmType: UpscaleAlgorithmType.RealESRGAN,
                  modelType: modelType,
                  modelTypeChoices: const ['realesr-animevideov3', 'realesrgan-x4plus-anime', 'realesrgan-x4plus'],
                  onChanged: (String? value) {
                    setState(() => modelType = value!);
                  },
                ),
                const SizedBox(height: 20),
                UpscaleRatioDropdownWidget(
                  upscaleAlgorithmType: UpscaleAlgorithmType.RealESRGAN,
                  upscaleRatio: upscaleRatio,
                  upscaleRatioChoices: const ['4x', '3x', '2x'],
                  onChanged: (String? value) {
                    setState(() => upscaleRatio = value!);
                  },
                ),
                const SizedBox(height: 20),
                OutputFormatDropdownWidget(
                  outputFormat: outputFormat,
                  onChanged: (String? value) {
                    setState(() => outputFormat = value!);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const Spacer(),
          StartButtonAndProgressBarWidget(
            isProcessing: isProcessing,
            progressPercentage: progressPercentage,
            onButtonPressed: upscaleImage,
          ),
        ],
      ),
    );
  }
}
