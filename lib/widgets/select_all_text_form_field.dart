// widgets/select_all_text_field.dart

import 'package:flutter/material.dart';

/// TextFormField que selecciona todo el texto al recibir el foco,
/// facilitando la edición directa sin necesidad de mover el cursor.
class SelectAllTextFormField extends StatefulWidget {
  const SelectAllTextFormField({
    super.key,
    this.initialValue,
    required this.decoration,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.onSaved,
    this.onChanged,
    this.validator,
  });

  final String? initialValue;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  State<SelectAllTextFormField> createState() => _SelectAllTextFormFieldState();
}

class _SelectAllTextFormFieldState extends State<SelectAllTextFormField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Seleccionar todo en el siguiente frame para que el campo
        // ya esté renderizado cuando se aplica la selección
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.text.length,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      textAlign: widget.textAlign,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      validator: widget.validator,
    );
  }
}
