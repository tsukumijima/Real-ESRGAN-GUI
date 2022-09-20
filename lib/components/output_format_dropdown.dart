
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OutputFormatDropdownWidget extends StatelessWidget {
  const OutputFormatDropdownWidget({
    super.key,
    required this.outputFormat,
    required this.onChanged,
  });

  final String outputFormat;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text('label.format'.tr(), style: const TextStyle(fontSize: 16)),
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
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
