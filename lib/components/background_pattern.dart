import 'package:flutter/material.dart';
import 'package:task_manager/app/theme/app_colors.dart' as app_colors;

class BackgroundPattern extends StatelessWidget {
  final Widget child;
  final Widget? firstButton; // Accept the entire first button as a widget
  final Widget? secondButton;
  final bool? showBottomLinearGradient; // Accept the entire second button as a widget

  const BackgroundPattern({
    Key? key,
    required this.child,
    this.firstButton,
    this.secondButton,
    this.showBottomLinearGradient = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: app_colors.backgroundColor, // Set background color
        child: Column(
          children: [
            Container(
              height: 4, // Height of the gradient divider
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3), // Start color of the gradient
                    Colors.black.withOpacity(0.1), // End color of the gradient
                  ],
                ),
              ),
            ),

            Expanded(child: child),
            if (showBottomLinearGradient == true)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.15), Colors.black.withOpacity(0.02)],
                  ),
                ),
              ),
            //Divider(height: 2, color: Colors.black),
            if (firstButton != null || secondButton != null)
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      if (secondButton != null)
                        Expanded(
                          flex: 1, // 1/3 of the space
                          child: secondButton!,
                        ),
                      if (secondButton != null) const SizedBox(width: 12), // Space between buttons
                      Expanded(
                        flex: 2, // 2/3 of the space
                        child: firstButton ?? SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
