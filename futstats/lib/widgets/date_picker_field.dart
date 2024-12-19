import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.labelText,
    required this.onDateSelected,
  });

  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String labelText;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          locale: Localizations.localeOf(context),
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: labelText),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat.yMd(Localizations.localeOf(context).toString())
                .format(initialDate ?? DateTime.now())),
            const Icon(Icons.calendar_month),
          ],
        ),
      ),
    );
  }
}
