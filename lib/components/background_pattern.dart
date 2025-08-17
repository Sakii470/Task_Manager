import 'package:flutter/material.dart';
import 'package:task_manager/app/theme/app_colors.dart' as app_colors;

class BackgroundPattern extends StatelessWidget {
  final Widget child;

  final bool? showBottomLinearGradient;

  const BackgroundPattern({Key? key, required this.child, this.showBottomLinearGradient = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: app_colors.backgroundColor,
        child: Column(
          children: [
            Container(
              height: 4,
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
          ],
        ),
      ),
    );
  }
}
