
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum DenoiseLevel {
  conservative,
  none,
  denoise1x,
  denoise2x,
  denoise3x,
}

class DenoiseLevelDropdownWidget extends StatelessWidget {
  const DenoiseLevelDropdownWidget({
    super.key,
    required this.denoiseLevel,
    required this.modelType,
    required this.upscaleRatio,
    required this.onChanged,
  });

  final DenoiseLevel denoiseLevel;
  final String modelType;
  final String upscaleRatio;
  final void Function(DenoiseLevel?) onChanged;

  @override
  Widget build(BuildContext context) {

    // ドロップダウンメニューを動的に生成する
    List<DropdownMenuItem<DenoiseLevel>> dropdownMenuItems = [];
    for (var denoiseLevel in DenoiseLevel.values) {

      var isEnabled = true;
      switch (modelType) {
        // モデルタイプが models-pro の場合: denoise1x と denoise2x のモデルはないので無効化
        case 'models-pro':
          if (denoiseLevel == DenoiseLevel.denoise1x) isEnabled = false;
          if (denoiseLevel == DenoiseLevel.denoise2x) isEnabled = false;
          break;
        // モデルタイプが models-se の場合: 拡大率 3x・4x には denoise1x と denoise2x のモデルはないので無効化
        case 'models-se':
          if (upscaleRatio != '2x' && denoiseLevel == DenoiseLevel.denoise1x) isEnabled = false;
          if (upscaleRatio != '2x' && denoiseLevel == DenoiseLevel.denoise2x) isEnabled = false;
          break;
        // モデルタイプが models-nose の場合: none 以外のモデルはないので無効化
        case 'models-nose':
          if (denoiseLevel == DenoiseLevel.conservative) isEnabled = false;
          if (denoiseLevel == DenoiseLevel.denoise1x) isEnabled = false;
          if (denoiseLevel == DenoiseLevel.denoise2x) isEnabled = false;
          if (denoiseLevel == DenoiseLevel.denoise3x) isEnabled = false;
          break;
      }

      dropdownMenuItems.add(DropdownMenuItem(
        value: denoiseLevel,
        enabled: isEnabled,
        child: Text('denoise.${denoiseLevel.name}'.tr(), style: TextStyle(color: isEnabled ? Colors.black : Colors.black38)),
      ));
    }

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text('ノイズ除去: '.tr(), style: const TextStyle(fontSize: 16)),
        ),
        Expanded(
          child: DropdownButtonFormField(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            value: denoiseLevel,
            items: dropdownMenuItems,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
