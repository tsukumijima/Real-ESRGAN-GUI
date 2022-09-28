
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OutputFormatDropdownWidget extends StatelessWidget {
  const OutputFormatDropdownWidget({
    super.key,
    required this.outputFormat,
    required this.onChanged,
    this.labelTextAlign = TextAlign.left,
  });

  final String outputFormat;
  final void Function(String?) onChanged;
  final TextAlign labelTextAlign;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text('label.format'.tr(), style: const TextStyle(fontSize: 16), textAlign: labelTextAlign),
        ),
        Expanded(
          child: DropdownButtonFormField(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            value: outputFormat,
            items: [
              DropdownMenuItem(
                value: 'jpg',
                child: const Text('format.jpeg').tr(),
              ),
              DropdownMenuItem(
                value: 'png',
                child: const Text('format.png').tr(),
              ),
              DropdownMenuItem(
                value: 'webp',
                child: const Text('format.webp').tr(),
              ),
            ],
            isExpanded: true,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
