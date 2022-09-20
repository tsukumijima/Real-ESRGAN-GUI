
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:real_esrgan_gui/components/io_form.dart';

enum UpscaleAlgorithmType {
  RealESRGAN,
}

/// 入出力フォームのバリデーションを行う
Future<bool> validateIOForm({
  required BuildContext context,
  required IOFormMode ioFormMode,
  required TextEditingController inputFileController,
  required TextEditingController outputFileController,
  required TextEditingController inputFolderController,
  required TextEditingController outputFolderController,
}) async {

  // バリデーション (ファイル選択モード)
  if (ioFormMode == IOFormMode.fileSelection) {

    // 入力元ファイルが指定されていない
    if (inputFileController.text == '') {
      showSnackBar(context: context, content: const Text('message.noInputFile').tr());
      return false;
    }

    // 出力先ファイルが指定されていない
    if (outputFileController.text == '') {
      showSnackBar(context: context, content: const Text('message.noOutputFilePath').tr());
      return false;
    }

    // 不正なファイルパスでないかの確認
    try {
      await Directory(path.dirname(outputFileController.text)).exists();
    } on FileSystemException {
      showSnackBar(context: context, content: const Text('message.invalidOutputFilePath').tr());
      return false;
    }

    // 出力先ファイルが既に存在する場合
    // 上書きするかの確認を取る
    if (await File(outputFileController.text).exists()) {
      var overwrite = false;
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return AlertDialog(
            title: const Text('label.overwriteConfirm').tr(),
            content: const Text('message.overwriteFileConfirm').tr(args: [outputFileController.text]),
            actionsPadding: const EdgeInsets.only(right: 12, bottom: 12),
            actions: [
              TextButton(
                child: const Text('label.cancel').tr(),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('label.overwriteFile').tr(),
                onPressed: () {
                  overwrite = true;
                  Navigator.pop(context);
                }
              ),
            ],
          );
        },
      );
      // キャンセルされたら実行しない
      if (overwrite == false) return false;
    }

  // バリデーション (フォルダ選択モード)
  } else if (ioFormMode == IOFormMode.folderSelection) {

    // 入力元フォルダが指定されていない
    if (inputFolderController.text == '') {
      showSnackBar(context: context, content: const Text('message.noInputFolder').tr());
      return false;
    }

    // 出力先ファイルが指定されていない
    if (outputFolderController.text == '') {
      showSnackBar(context: context, content: const Text('message.noOutputFolderPath').tr());
      return false;
    }

    // 不正なフォルダパスでないかの確認
    try {
      await Directory(outputFolderController.text).exists();
    } on FileSystemException {
      showSnackBar(context: context, content: const Text('message.invalidOutputFolderPath').tr());
      return false;
    }

    // 出力先フォルダが既に存在する場合
    // 上書きするかの確認を取る
    if (await Directory(outputFolderController.text).exists()) {
      var overwrite = false;
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return AlertDialog(
            title: const Text('label.overwriteConfirm').tr(),
            content: const Text('message.overwriteFolderConfirm').tr(args: [outputFolderController.text]),
            actionsPadding: const EdgeInsets.only(right: 12, bottom: 12),
            actions: [
              TextButton(
                child: const Text('label.cancel').tr(),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('label.overwriteFolder').tr(),
                onPressed: () {
                  overwrite = true;
                  Navigator.pop(context);
                }
              ),
            ],
          );
        },
      );
      // キャンセルされたら実行しない
      if (overwrite == false) return false;
    }
  }

  // ここまでのバリデーションをすべて通過したときだけ true を返す
  return true;
}

/// 簡単に SnackBar を表示する
void showSnackBar({required BuildContext context, required Widget content, Duration? duration}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: content,
    duration: duration ?? const Duration(milliseconds: 4000),
    action: SnackBarAction(
      label: 'label.close'.tr(),
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  ));
}
