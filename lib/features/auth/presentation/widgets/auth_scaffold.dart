import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_center.dart';

/// Scrollable, keyboard-safe layout shared by the auth screens.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: title == null
        ? null
        : AppBar(
            title: Text(title!),
            leading: Navigator.of(context).canPop()
                ? IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  )
                : null,
          ),
    body: SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ResponsiveCenter(maxWidth: 480, child: child),
      ),
    ),
  );
}
