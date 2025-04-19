
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantitySelector extends StatefulWidget {
  final int initialValue;
  final int initialStep;

  final void Function(int) onChanged;

  const QuantitySelector({super.key, this.initialValue = 5, this.initialStep = 5, required this.onChanged});

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int quantity;

  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    quantity = widget.initialValue;
    updateTextField();
  }

  void updateQuantity(int newQty) {
    setState(() {
      quantity = newQty;
      updateTextField();

    } );
    widget.onChanged(quantity);

  }

  void updateTextField()
  {
    textController.text= quantity.toString();
  }

  void onAdd()
  {
    updateQuantity(quantity + widget.initialStep);
    FocusScope.of(context).unfocus();
  }

  void onSubtract()
  {
    updateQuantity(quantity - widget.initialStep);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove_circle),
          onPressed: quantity>1?onSubtract:null,
        ),
        SizedBox(
          width: 50,
          child: TextField(
            controller: textController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: Colors.black45,    // Your desired text color
              fontSize: 22,
              fontWeight: FontWeight.bold
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(4),
              hintText: '',
              hintStyle: TextStyle(color: Colors.black26),
              border: InputBorder.none,             // No border by default
              enabledBorder: InputBorder.none,      // No border when idle
              focusedBorder: OutlineInputBorder(    // Rectangle when focused
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),

              // suffixText: 'min',
              // suffixStyle: TextStyle(color: Colors.black),  // Style for prefix
              // contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),


        ),
        Text('min', style: TextStyle(fontSize: 14,color: Colors.black45)),
        IconButton(
          icon: Icon(Icons.add_circle),
          onPressed: onAdd,
        ),
      ],
    );
  }
}
