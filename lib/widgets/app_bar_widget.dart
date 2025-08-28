import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MeoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final bool showBackButton;
  final String? title;
  final VoidCallback? onBackPressed;
  
  const MeoAppBar({
    super.key, 
    this.actions, 
    this.showBackButton = false,
    this.title,
    this.onBackPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Stack(
        children: [
          // 火箭图标固定在左侧
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 16,
                  height: 16,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // meo 文本居中
          Center(
            child: Text(
              title ?? 'meo', 
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? BackButton(
              onPressed: onBackPressed ?? () => context.go('/'),
            )
          : null,
      actions: actions,
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}