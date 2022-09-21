
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StartButtonAndProgressBarWidget extends StatelessWidget {
  const StartButtonAndProgressBarWidget({
    super.key,
    required this.isProcessing,
    required this.progressPercentage,
    required this.onButtonPressed,
  });

  final bool isProcessing;
  final double progressPercentage;
  final void Function() onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 212,
            height: 54,
            child: ElevatedButton.icon(
              // 拡大開始ボタンが押されたとき
              onPressed: onButtonPressed,
              icon: Icon(isProcessing ? Icons.cancel : Icons.image_rounded),
              label: Text(isProcessing ? 'label.cancel'.tr() : 'label.start'.tr(), style: const TextStyle(fontSize: 20, height: 1.3)),
              style: ButtonStyle(
                backgroundColor: isProcessing ? const MaterialStatePropertyAll(Color(0xFFEE525A)) : null,
                foregroundColor: const MaterialStatePropertyAll(Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        LinearProgressIndicator(
          value: progressPercentage / 100,  // 100 で割った (0~1 の範囲) 値を与える
          minHeight: 20,
        ),
      ],
    );
  }
}
