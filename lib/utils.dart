
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
