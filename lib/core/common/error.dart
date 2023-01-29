import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;
  const ErrorText({
    Key? key,
    required this.error,
    required this.stackTrace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: SelectionArea(
        child: Column(
          children: [
            Text(
              error.toString(),
            ),
            Text(stackTrace.toString()),
          ],
        ),
      ),
    );
  }
}
