
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
      dropdownMenuItems.add(DropdownMenuItem(
        value: denoiseLevel,
        child: Text('denoise.${denoiseLevel.name}'.tr()),
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
