import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExitConfirmWrapper extends StatelessWidget {
  const ExitConfirmWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  // Función que muestra el diálogo de confirmación
  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Salir'),
          content: const Text('¿Realmente desea salir de la app?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit ?? false) {
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
