
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:real_esrgan_gui/utils.dart';

class ModelTypeDropdownWidget extends StatelessWidget {
  const ModelTypeDropdownWidget({
    super.key,
    required this.upscaleAlgorithmType,
    required this.modelTypes,
    required this.modelType,
    required this.onChanged,
  });

  final UpscaleAlgorithmType upscaleAlgorithmType;
  final List<String> modelTypes;
  final String modelType;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {

    // ドロップダウンメニューを動的に生成する
    List<DropdownMenuItem<String>> dropdownMenuItems = [];
    for (var modelType in modelTypes) {
      dropdownMenuItems.add(DropdownMenuItem(
        value: modelType,
        child: Text('model.${upscaleAlgorithmType.name}.${modelType}').tr(),
      ));
    }

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text('label.model'.tr(), style: const TextStyle(fontSize: 16)),
        ),
        Expanded(
          child: DropdownButtonFormField(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            value: modelType,
            items: dropdownMenuItems,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
