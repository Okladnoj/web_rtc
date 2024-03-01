import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final double strokeWidth;

  const AppLoader({
    super.key,
    this.strokeWidth = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 100.0,
        width: 100.0,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          backgroundColor: Colors.indigoAccent.withOpacity(0.5),
          color: Colors.indigoAccent,
        ),
      ),
    );
  }
}
