import 'dart:ui';
import 'package:flutter/material.dart';

class BlurOverlay extends StatelessWidget {
  final Widget child;
  final bool isBlurred;
  final String message;
  final VoidCallback? onTap;

  const BlurOverlay({
    super.key,
    required this.child,
    required this.isBlurred,
    this.message = 'Çözümünüzü gönderdikten sonra\ndiğer çözümleri görebilirsiniz',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isBlurred) {
      return child;
    }

    return Stack(
      children: [
        // Blurred content
        child,
        
        // Blur effect
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.upload),
                        label: const Text('Çözüm Gönder'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
