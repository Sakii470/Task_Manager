import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onBack;
  final Color backgroundColor;
  final Color iconColor;
  final IconData? rightIcon;
  final VoidCallback? onRightIconPressed;
  final TabController? tabController;
  final List<Tab>? tabs;
  final List<Widget>? customFilters; // New: List of custom widgets
  final bool? showBackArrow;
  final Widget? rightButton;

  const CustomHeader({
    Key? key,
    this.title,
    this.onBack,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.rightIcon,
    this.onRightIconPressed,
    this.tabController,
    this.tabs,
    this.customFilters, // New
    this.showBackArrow = true,
    this.rightButton,
  }) : super(key: key);

  @override
  Size get preferredSize {
    double height = 0; // Start with 0 height
    if (showBackArrow == true) {
      height += 50; // Add height for the back arrow row
    }
    if (tabs != null && tabController != null) {
      height += 50; // Add height for tabs
    }
    if (title != null) {
      height += 35; // Add height for title
    }
    if (customFilters != null && customFilters!.isNotEmpty) {
      height += 50; // Add height for custom widgets
    }
    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 0, right: 0, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBackArrow == true)
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: iconColor),
                  onPressed: onBack ?? () => context.pop(),
                ),
                Expanded(child: Container()), // Spacer
                if (rightIcon != null)
                  IconButton(
                    icon: Icon(rightIcon, color: iconColor),
                    onPressed: onRightIconPressed,
                  ),
                if (rightButton != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0), // Add padding
                    child: rightButton!,
                  ),
              ],
            ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                title!,
                style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          if (tabs != null && tabController != null)
            TabBar(
              controller: tabController,
              tabs: tabs!,
              dividerColor: Colors.transparent,
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                color: Colors.transparent, // Remove underline
              ),
              indicatorSize: TabBarIndicatorSize.tab,
            ),
          if (customFilters != null && customFilters!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: customFilters!,
              ),
            ),
        ],
      ),
    );
  }
}
