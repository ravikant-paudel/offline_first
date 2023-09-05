import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String cta;
  VoidCallback onPressed;

  MyButton({
    super.key,
    required this.cta,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: Theme.of(context).colorScheme.primary,
      child: Text(cta),
    );
  }
}
