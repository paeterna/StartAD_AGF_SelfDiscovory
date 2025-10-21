import 'package:flutter/material.dart';

/// Custom AppBar with logo and title
class LogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LogoAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Row(
        children: [
          // Logo
          Image.asset(
            'assets/images/logo.png',
            height: 32,
            width: 32,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
