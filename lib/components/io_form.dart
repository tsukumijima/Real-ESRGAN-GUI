
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

enum IOFormMode {
  fileSelection,
  folderSelection,
}

class IOFormWidget extends StatefulWidget {
  const IOFormWidget({
    super.key,
    required this.inputFileController,
    required this.outputFileController,
    required this.inputFolderController,
    required this.outputFolderController,
    required this.upscaleRatio,
    required this.outputFormat,
    required this.onModeChanged,
    required this.onOutputFormatChanged,
  });

  final String upscaleRatio;
  final String outputFormat;
  final TextEditingController inputFileController;
  final TextEditingController outputFileController;
  final TextEditingController inputFolderController;
  final TextEditingController outputFolderController;
  final Function(IOFormMode) onModeChanged;
  final Function(String) onOutputFormatChanged;

  @override
  State<IOFormWidget> createState() => IOFormWidgetState();
}

class IOFormWidgetState extends State<IOFormWidget> with SingleTickerProviderStateMixin {

  // ファイル or フォルダを切り替えるタブのコントローラー
  late TabController fileOrFolderTabController;

  // 親 Widget からの値更新を検知するための変数
  String savedUpscaleRatio = 'jpg';
  String savedOutputFormat = '4x';

  @override
  void initState() {
    super.initState();

    // TabController を初期化し、タブが切り替えられたときのイベントを定義
    fileOrFolderTabController = TabController(length: 2, vsync: this);
    fileOrFolderTabController.addListener((){
      if (fileOrFolderTabController.index == 0) {
        // ファイル選択タブに変更されたとき、フォルダ選択タブのフォームをリセットする
        widget.inputFolderController.text = '';
        widget.outputFolderController.text = '';
        widget.onModeChanged(IOFormMode.fileSelection);  // コールバックを呼び出し
      } else if (fileOrFolderTabController.index == 1) {
        // フォルダ選択タブに変更されたとき、ファイル選択タブのフォームをリセットする
        widget.inputFileController.text = '';
        widget.outputFileController.text = '';
        widget.onModeChanged(IOFormMode.folderSelection);  // コールバックを呼び出し
      }
    });
  }

  /// 保存先のファイル/フォルダパスを更新する
  void updateOutputName(String upscaleRatio, String outputFormat) {

    var inputFilePath = widget.inputFileController.text;
    var inputFolderPath = widget.inputFolderController.text;

    // ファイル選択モード & 拡大元の画像ファイルが選択されている
    if (fileOrFolderTabController.index == 0 && inputFilePath != '') {

      // 保存形式が拡大元の画像ファイルと同じなら、拡張子には拡大元の画像ファイルと同じものを使う
      var extension = outputFormat;
      if (extension == path.extension(inputFilePath).toLowerCase().replaceAll('jpeg', 'jpg').replaceAll('.', '')) {
        extension = path.extension(inputFilePath).replaceAll('.', '');
      }

      // 保存先のファイルパスを (入力画像のファイル名)-upscale-4x.jpg みたいなのに設定
      // 4x の部分は拡大率によって変わる
      // jpg の部分は保存形式によって変わる
      widget.outputFileController.text = '${path.withoutExtension(inputFilePath)}-upscale-${upscaleRatio}.${extension}';

    // フォルダ選択モード & 拡大元の画像フォルダが選択されている
    } else if (fileOrFolderTabController.index == 1 && inputFolderPath != '') {

      // 保存先のフォルダパスを (入力画像のフォルダ名)-upscale-4x みたいなのに設定
      // 4x の部分は拡大率によって変わる
      // jpg の部分は保存形式によって変わる
      widget.outputFolderController.text = '${inputFolderPath}-upscale-${upscaleRatio}';
    }
  }

  @override
  Widget build(BuildContext context) {

    // 保存先のファイル/フォルダパスフォームのテキストを更新
    // savedUpscaleRatio または savedOutputFormat が親 Widget 側から変更された (親 Widget から IOFormWidget が再ビルドされた) ときのみ実行する
    // IOFormWidget が持つ変数はすべて不変なので、もし値が変わるとしたら再ビルドされたとき以外考えられない
    if (savedUpscaleRatio != widget.upscaleRatio || savedOutputFormat != widget.outputFormat) {
      updateOutputName(widget.upscaleRatio, widget.outputFormat);
    }

    // 親 Widget からの値変更があったかの判定が終わったので、親 Widget から渡された値に更新
    savedUpscaleRatio = widget.upscaleRatio;
    savedOutputFormat = widget.outputFormat;

    return Column(
      children: [
        TabBar(
          controller: fileOrFolderTabController,
          tabs: const [
            Tab(child: Text('ファイル選択', style: TextStyle(color: Colors.green, fontSize: 16))),
            Tab(child: Text('フォルダ選択（一括処理）', style: TextStyle(color: Colors.green, fontSize: 16))),
          ],
        ),
        Column(
          children: [
            SizedBox(
              height: 158,
              child: TabBarView(
                controller: fileOrFolderTabController,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          // Expanded で挟まないとエラーになる
                          Expanded(
                            child: TextField(
                              readOnly: true,
                              controller: widget.inputFileController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'label.inputFile'.tr(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              // ファイル選択ボタンが押されたとき
                              onPressed: () async {

                                // 選択を許可する拡張子の一覧
                                final imageTypeGroup = XTypeGroup(
                                  label: 'images',
                                  extensions: <String>['jpg', 'jpeg', 'png', 'webp'],
                                );

                                // ファイルピッカーを開き、選択されたファイルを格納
                                var inputFile = await openFile(acceptedTypeGroups: <XTypeGroup>[imageTypeGroup]);

                                // もし拡大元の画像ファイルが入っていれば、フォームにファイルパスを設定
                                if (inputFile != null) {
                                  setState(() {

                                    // 拡大元の画像フォルダフォームのテキストを更新
                                    widget.inputFileController.text = inputFile.path;

                                    // 新しい保存形式を拡大元の画像ファイルの拡張子から取得
                                    // 拡張子が .jpeg だった場合も jpg に統一するほか、拡張子が大文字の場合も小文字にする
                                    var outputFormat = path.extension(inputFile.path).toLowerCase().replaceAll('jpeg', 'jpg').replaceAll('.', '');

                                    // 保存形式変更のコールバックを呼ぶ
                                    widget.onOutputFormatChanged(outputFormat);

                                    // 保存先のフォルダパスフォームのテキストを更新
                                    updateOutputName(widget.upscaleRatio, outputFormat);
                                  });

                                // ファイル選択がキャンセルされたので、フォームをリセット
                                } else {
                                  widget.inputFileController.text = '';
                                  widget.outputFileController.text = '';
                                }
                              },
                              icon: const Icon(Icons.file_open_rounded),
                              label: Text('label.imageSelect'.tr(), style: const TextStyle(fontSize: 16, height: 1.3)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: widget.outputFileController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'label.outputFilePath'.tr(),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          // Expanded で挟まないとエラーになる
                          Expanded(
                            child: TextField(
                              readOnly: true,
                              controller: widget.inputFolderController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'label.inputFolder'.tr(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              // フォルダ選択ボタンが押されたとき
                              onPressed: () async {

                                // フォルダピッカーを開き、選択されたフォルダのパスを格納
                                var inputFolderPath = await FilePicker.platform.getDirectoryPath(dialogTitle: '開く');

                                // もし拡大元の画像フォルダのパスが入っていれば、フォームにフォルダパスを設定
                                if (inputFolderPath != null) {
                                  setState(() {

                                    // 拡大元の画像フォルダフォームのテキストを更新
                                    widget.inputFolderController.text = inputFolderPath;

                                    // 保存先のフォルダパスフォームのテキストを更新
                                    // ファイル選択と異なり保存形式は変更されないので、親 Widget から渡された値をそのまま使う
                                    updateOutputName(widget.upscaleRatio, widget.outputFormat);
                                  });

                                // フォルダ選択がキャンセルされたので、フォームをリセット
                                } else {
                                  widget.inputFolderController.text = '';
                                  widget.outputFolderController.text = '';
                                }
                              },
                              icon: const Icon(Icons.snippet_folder_rounded),
                              label: Text('label.folderSelect'.tr(), style: const TextStyle(fontSize: 16, height: 1.3)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: widget.outputFolderController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'label.outputFolderPath'.tr(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
