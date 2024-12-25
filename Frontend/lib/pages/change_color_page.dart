import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../resources/theme/theme.dart';

class ChangeColorPage extends StatelessWidget {
  const ChangeColorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;

    return Scaffold(
      backgroundColor: palette.color50,
      body: Stack(
        children: [
          ExitButton(
            onPress: () =>{
              Navigator.pop(context)
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonWidget(
                  text: "Розовый",
                  onPress: () {
                    Provider.of<AppTheme>(context, listen: false)
                        .switchToLightTheme();
                  },
                ),
                SizedBox(height: 20),
                ButtonWidget(
                  text: "Темно розовый",
                  onPress: () {
                    Provider.of<AppTheme>(context, listen: false)
                        .switchToDarkTheme();
                  },
                ),
                SizedBox(height: 20),
                ButtonWidget(
                  text: "Зеленый",
                  onPress: () {
                    Provider.of<AppTheme>(context, listen: false)
                        .switchToGreenTheme();
                  },
                ),
                SizedBox(height: 20),
                ButtonWidget(
                  text: "Голубой",
                  onPress: () {
                    Provider.of<AppTheme>(context, listen: false)
                        .switchToBlueTheme();
                  },
                ),
                SizedBox(height: 20),
                ButtonWidget(
                  text: "Коричневый",
                  onPress: () {
                    Provider.of<AppTheme>(context, listen: false)
                        .switchToBrownTheme();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  final VoidCallback onPress;
  final String text;

  const ButtonWidget({super.key, required this.onPress, required this.text});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;
    return TextButton(
        onPressed: onPress,
        style: ButtonStyle(
          alignment: Alignment.center,
          // maximumSize: WidgetStatePropertyAll(Size(300, 75)),
          // minimumSize: WidgetStatePropertyAll((Size(150, 75))),
          fixedSize: WidgetStatePropertyAll(Size(300, 75)),
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
              if (states.contains(WidgetState.hovered)) {
                return palette.color300;
              }
              // else if (states.contains(WidgetState.pressed)) {
              //   return palette.color900;}
              else if (states.contains(WidgetState.focused)) {
                return palette.color300;
              }
              return palette.color100;
            },
          ),

          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child: Text(text));
  }
}

class ExitButton extends StatelessWidget {
  final VoidCallback onPress;

  const ExitButton({
    super.key,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;

    return Padding(
      padding: EdgeInsets.all(20),
      child: IconButton(
        onPressed: onPress,
        icon: Icon(Icons.logout),
        constraints: BoxConstraints(
          minWidth: 70.0,
          minHeight: 70.0,
        ),
        focusNode: FocusNode(skipTraversal: true),
        color: palette.color50,
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          shadowColor: WidgetStatePropertyAll(Colors.black),
          elevation: WidgetStatePropertyAll(2),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.hovered)) {
                return palette.color800;
              }
              return palette.color900;
            },
          ),
        ),
      ),
    );
  }
}
