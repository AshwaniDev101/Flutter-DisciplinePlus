
import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final int initialValue;
  final void Function(int) onChanged;

  const QuantitySelector({super.key, this.initialValue = 1, required this.onChanged});

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialValue;
  }

  void updateQuantity(int newQty) {
    setState(() => quantity = newQty);
    widget.onChanged(quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: quantity > 1 ? () => updateQuantity(quantity - 1) : null,
        ),
        Text('$quantity', style: TextStyle(fontSize: 18)),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => updateQuantity(quantity + 1),
        ),
      ],
    );
  }
}
