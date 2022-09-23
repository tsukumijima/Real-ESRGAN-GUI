
import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:real_esrgan_gui/components/io_form.dart';
import 'package:real_esrgan_gui/components/denoise_level_dropdown.dart';
import 'package:real_esrgan_gui/components/model_type_dropdown.dart';
import 'package:real_esrgan_gui/components/output_format_dropdown.dart';
import 'package:real_esrgan_gui/components/start_button_and_progress_bar.dart';
import 'package:real_esrgan_gui/components/upscale_ratio_dropdown.dart';
import 'package:real_esrgan_gui/utils.dart';

class RealCUGANTabPage extends StatefulWidget {
  const RealCUGANTabPage({super.key});

  @override
  State<RealCUGANTabPage> createState() => RealCUGANTabPageState();
}

class RealCUGANTabPageState extends State<RealCUGANTabPage> {

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

  /// モデルの種類 (デフォルト: models-pro)
  /// "models-pro"・"models-se"・"models-nose" のいずれか
  String modelType = 'models-pro';

  /// ノイズ除去レベル (デフォルト: ディティールを保持)
  DenoiseLevel denoiseLevel = DenoiseLevel.conservative;

  /// 拡大率 (デフォルト: 2倍)
  /// "2x"・"3x"・"4x" のいずれか
  String upscaleRatio = '2x';

  /// 保存形式 (デフォルト: jpg (ただし既定で選択された拡大元画像の拡張子に変更される))
  /// "jpg"・"png"・"webp" のいずれか
  String outputFormat = 'jpg';

  // ***** プロセス実行関連 *****

  /// 拡大の進捗状況 (デフォルト: 0%)
  double? progressPercentage = 0;

  /// 拡大処理を実行中かどうか
  bool isProcessing = false;

  /// コマンドの実行プロセスのインスタンス
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
    List<Map<String, String>> imageFiles = await getInputFileWithOutputFilePairList(
      context: context,
      ioFormMode: ioFormMode,
      outputFormat: outputFormat,
      inputFileController: inputFileController,
      outputFileController: outputFileController,
      inputFolderController: inputFolderController,
      outputFolderController: outputFolderController,
    );
    if (imageFiles.isEmpty) return;

    // 画像ファイル1つごとに何%プログレスバーを進めるかの値
    // たとえば4つのファイルが処理対象なら、ここには 25 (%) が入る
    var progressStep = 100 / imageFiles.length;

    // プログレスバーをファイル選択モードのときはプログレスバーを無限に設定
    // フォルダ選択モードのときはとりあえず progressStep の10%に設定（なんも進んでないと誤解されないように）
    setState(() {
      if (ioFormMode == IOFormMode.fileSelection) {
        progressPercentage = null;
      } else {
        progressPercentage = progressStep * 0.1;
      }
      isProcessing = true;
    });

    // 画像ファイルごとに繰り返す
    for (var progressIndex = 0; progressIndex < imageFiles.length; progressIndex++) {

      // realcugan-ncnn-vulkan の実行ファイルのパスを取得
      var executablePath = getUpscaleAlgorithmExecutablePath(UpscaleAlgorithmType.RealCUGAN);

      // 実際に引数として与えるノイズ除去レベル
      String denoiseLevelArg;
      switch (denoiseLevel) {
        case DenoiseLevel.conservative:
          denoiseLevelArg = '-1';
          break;
        case DenoiseLevel.none:
          denoiseLevelArg = '0';
          break;
        case DenoiseLevel.denoise1x:
          denoiseLevelArg = '1';
          break;
        case DenoiseLevel.denoise2x:
          denoiseLevelArg = '2';
          break;
        case DenoiseLevel.denoise3x:
          denoiseLevelArg = '3';
          break;
      }

      // realcugan-ncnn-vulkan コマンドを実行
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
          '-m', modelType,
          // ノイズ除去レベル
          '-n', denoiseLevelArg,
          // 拡大率 (2x の x は除く)
          '-s', upscaleRatio.replaceAll('x', ''),
          // 保存形式
          '-f', outputFormat,
        ],
        workingDirectory: path.dirname(executablePath),
      );

      // 失敗したときにエラーログを表示するために受け取ったログを貯めておく
      List<String> lines = [];  // すべてのログを貯めるリスト
      process.stderr.transform(utf8.decoder).forEach((line) {
        lines.add(line);
      });

      // realcugan-ncnn-vulkan の終了を待つ
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
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'M PLUS 2',
        snackBarTheme: const SnackBarThemeData(
          contentTextStyle: TextStyle(fontFamily: 'M PLUS 2'),
        ),
      ),
      child: Column(
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
                  upscaleAlgorithmType: UpscaleAlgorithmType.RealCUGAN,
                  modelType: modelType,
                  modelTypeChoices: const ['models-pro', 'models-se', 'models-nose'],
                  onChanged: (String? value) {
                    setState(() => modelType = value!);

                    // モデルに応じてノイズ除去レベルや拡大率の対応状況が異なる
                    // ノイズ除去レベルや拡大率が変更されたモデルでは対応していない場合、別の値に変更する

                    // ノイズ除去の場合
                    switch (modelType) {
                      // モデルタイプが models-pro の場合: denoise1x と denoise2x のモデルはない
                      case 'models-pro':
                        if (denoiseLevel == DenoiseLevel.denoise1x || denoiseLevel == DenoiseLevel.denoise2x) {
                          setState(() => denoiseLevel = DenoiseLevel.denoise3x);
                        }
                        break;
                      // モデルタイプが models-se の場合: 拡大率 3x・4x には denoise1x と denoise2x のモデルはない
                      case 'models-se':
                        if (upscaleRatio != '2x') {
                          if (denoiseLevel == DenoiseLevel.denoise1x || denoiseLevel == DenoiseLevel.denoise2x) {
                            setState(() => denoiseLevel = DenoiseLevel.denoise3x);
                          }
                        }
                        break;
                      // モデルタイプが models-nose の場合: none 以外のモデルはない
                      case 'models-nose':
                        if (denoiseLevel != DenoiseLevel.none) {
                          setState(() => denoiseLevel = DenoiseLevel.none);
                        }
                        break;
                    }

                    // 拡大率の場合
                    switch (modelType) {
                      // モデルタイプが models-pro の場合: 拡大率 4x には対応していない
                      case 'models-pro':
                        if (upscaleRatio == '4x') setState(() => upscaleRatio = '3x');
                        break;
                      // モデルタイプが models-pro の場合: 拡大率 4x・3x には対応していない
                      case 'models-nose':
                        if (upscaleRatio == '4x' || upscaleRatio == '3x') setState(() => upscaleRatio = '2x');
                        break;
                    }
                  },
                ),
                const SizedBox(height: 20),
                DenoiseLevelDropdownWidget(
                  denoiseLevel: denoiseLevel,
                  modelType: modelType,
                  upscaleRatio: upscaleRatio,
                  onChanged: (DenoiseLevel? value) {
                    setState(() => denoiseLevel = value!);
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: UpscaleRatioDropdownWidget(
                        upscaleAlgorithmType: UpscaleAlgorithmType.RealCUGAN,
                        upscaleRatio: upscaleRatio,
                        modelType: modelType,
                        onChanged: (String? value) {
                          setState(() => upscaleRatio = value!);
                        },
                      ),
                    ),
                    Expanded(
                      child: OutputFormatDropdownWidget(
                        outputFormat: outputFormat,
                        onChanged: (String? value) {
                          setState(() => outputFormat = value!);
                        },
                        labelTextAlign: TextAlign.center,
                      ),
                    ),
                  ],
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
