
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:real_esrgan_gui/utils.dart';

class UpscaleRatioDropdownWidget extends StatelessWidget {
  const UpscaleRatioDropdownWidget({
    super.key,
    required this.upscaleAlgorithmType,
    required this.upscaleRatio,
    required this.upscaleRatioChoices,
    required this.onChanged,
  });

  final UpscaleAlgorithmType upscaleAlgorithmType;
  final String upscaleRatio;
  final List<String> upscaleRatioChoices;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {

    // ドロップダウンメニューを動的に生成する
    List<DropdownMenuItem<String>> dropdownMenuItems = [];
    for (var upscaleRatio in upscaleRatioChoices) {
      var text = 'scale.${upscaleRatio}'.tr();
      // 壊滅的な画像が表示されることがある旨を表示する
      // "アルゴリズムに Real-ESRGAN が選択されている" & "UI 言語が日本語" & "拡大率が 3x または 2x" のときだけ実行
      if ((upscaleAlgorithmType == UpscaleAlgorithmType.RealESRGAN) &&
          (context.locale.toString() == 'ja_JP') &&
          (upscaleRatio == '3x' || upscaleRatio == '2x')) {
        text += ' (壊滅的な画像が生成されることがあります)';
      }
      dropdownMenuItems.add(DropdownMenuItem(
        value: upscaleRatio,
        child: Text(text),
      ));
    }

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text('label.scale'.tr(), style: const TextStyle(fontSize: 16)),
        ),
        Expanded(
          child: DropdownButtonFormField(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            value: upscaleRatio,
            items: dropdownMenuItems,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
