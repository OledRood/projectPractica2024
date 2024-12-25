
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../resources/theme/theme.dart';

class RedButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final double width;
  final double height;
  final bool focus;

  const RedButtonWidget({
    super.key,
    required this.onTap,
    required this.text, required this.width, required this.height, required this.focus,
  });


  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;
    return TextButton(
        onPressed: onTap,
        focusNode: focus ? null : FocusNode(skipTraversal: true),
        style: ButtonStyle(
          alignment: Alignment.center,
          fixedSize: WidgetStatePropertyAll(Size(width, height)),
          shadowColor: WidgetStatePropertyAll(Colors.black),
          elevation: WidgetStatePropertyAll(2),
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return palette.color900.withOpacity(0.3);
              }
              return null;
            },
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (states) {
              //При наведении
              if (states.contains(WidgetState.hovered)) {
                return palette.color800;
              } else if (states.contains(WidgetState.focused)) {
                return palette.color700;
              }
              //Изначально
              return palette.color900;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                (states) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.white;
              } else if (states.contains(WidgetState.focused)) {
                return Colors.white;
              }
              return palette.color50;
            },
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
        child: Text(text));
  }
}