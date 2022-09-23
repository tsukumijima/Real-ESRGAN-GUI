
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:real_esrgan_gui/utils.dart';

class UpscaleRatioDropdownWidget extends StatelessWidget {
  const UpscaleRatioDropdownWidget({
    super.key,
    required this.upscaleAlgorithmType,
    required this.upscaleRatio,
    required this.modelType,
    required this.onChanged,
  });

  final UpscaleAlgorithmType upscaleAlgorithmType;
  final String upscaleRatio;
  final String modelType;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {

    List<String> upscaleRatioOrder;
    switch (upscaleAlgorithmType) {
      case UpscaleAlgorithmType.RealESRGAN:
        upscaleRatioOrder = ['4x', '3x', '2x'];
        break;
      case UpscaleAlgorithmType.RealCUGAN:
        upscaleRatioOrder = ['2x', '3x', '4x'];
        break;
    }

    // ドロップダウンメニューを動的に生成する
    List<DropdownMenuItem<String>> dropdownMenuItems = [];
    for (var upscaleRatioLocal in upscaleRatioOrder) {

      // 壊滅的な画像が表示されることがある旨を表示する
      // "アルゴリズムに Real-ESRGAN が選択されている" & "UI 言語が日本語" & "拡大率が 3x または 2x" のときだけ実行
      var text = 'scale.${upscaleRatioLocal}'.tr();
      if ((upscaleAlgorithmType == UpscaleAlgorithmType.RealESRGAN) &&
          (context.locale.toString() == 'ja_JP') &&
          (upscaleRatioLocal == '3x' || upscaleRatioLocal == '2x')) {
        text += ' (壊滅的な画像が生成されることがあります)';
      }

      var isEnabled = true;
      switch (modelType) {
        // モデルタイプが models-pro の場合: 拡大率 4x には対応していない
        case 'models-pro':
          if (upscaleRatioLocal == '4x') isEnabled = false;
          break;
        // モデルタイプが models-pro の場合: 拡大率 4x・3x には対応していない
        case 'models-nose':
          if (upscaleRatioLocal == '4x' || upscaleRatioLocal == '3x') isEnabled = false;
          break;
      }

      dropdownMenuItems.add(DropdownMenuItem(
        value: upscaleRatioLocal,
        enabled: isEnabled,
        child: Text(text, style: TextStyle(color: isEnabled ? Colors.black : Colors.black38)),
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
            isExpanded: true,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
