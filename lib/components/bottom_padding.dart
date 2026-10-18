import 'package:flutter/widgets.dart';

class BottomPadding extends StatelessWidget {
  const BottomPadding({super.key});

  static double of(BuildContext context, {double minimum = 16}) {
    // Altura da barra inferior do sistema
    final double viewPadding = MediaQuery.viewPaddingOf(context).bottom;

    // Usa a altura da barra se for maior que o mínimo,
    // senão usa o mínimo.
    final double height = viewPadding > minimum ? viewPadding : minimum;

    return height;
  }

  @override
  Widget build(BuildContext context) {
    final double height = of(context);

    return SizedBox(height: height);
  }
}
