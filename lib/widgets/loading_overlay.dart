// widgets/loading_overlay.dart

import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child, // Contenido principal

        if (isLoading)
          Stack(
            children: [
              // Capa bloqueante semitransparente
              const ModalBarrier(
                dismissible: false,
                color: Colors.black54,
              ),
              
              // Indicador de carga centrado y mensaje opcional
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          )
      ],
    );
  }
}
