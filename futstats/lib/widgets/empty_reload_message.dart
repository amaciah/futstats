import 'package:flutter/material.dart';
import 'package:futstats/widgets/reload_button.dart';

class EmptyReloadMessage extends StatelessWidget {
  const EmptyReloadMessage({
    super.key,
    required this.message,
    required this.reloadAction,
  });

  final String message;
  final void Function() reloadAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          ReloadButton(onPressed: reloadAction),
        ],
      ),
    );
  }
}
