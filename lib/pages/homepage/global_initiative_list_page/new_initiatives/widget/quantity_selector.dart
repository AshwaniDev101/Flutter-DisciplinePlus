import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantitySelector extends StatefulWidget {
  final int initialValue;
  final int initialStep;

  final void Function(int) onChanged;

  const QuantitySelector({super.key, this.initialValue = 1, this.initialStep = 1, required this.onChanged});

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text = widget.initialValue.toString();
  }

  void updateQuantity(int newQty) {
    setState(() {
      textController.text = newQty.toString();
    });
    widget.onChanged(int.parse(textController.text));
  }

  void onAdd() {
    updateQuantity(int.parse(textController.text) + widget.initialStep);
    FocusScope.of(context).unfocus();
  }

  void onSubtract() {
    updateQuantity(int.parse(textController.text) - widget.initialStep);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (int.parse(textController.text) > 1)
          _RoundButton(
            text: "-${widget.initialStep}",
            onClick: onSubtract,
            fontSize: 12,
          ),
        SizedBox(
          width: 5,
        ),
        SizedBox(
          width: 50,
          child: TextField(
            controller: textController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
                color: Colors.black45, // Your desired text color
                fontSize: 20,
                fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(4),
              hintText: '',
              hintStyle: TextStyle(color: Colors.black26),
              border: InputBorder.none,
              // No border by default
              enabledBorder: InputBorder.none,
              // No border when idle
              focusedBorder: OutlineInputBorder(
                // Rectangle when focused
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),

              // contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            onChanged: (value) {
              updateQuantity(int.parse(value));
            },
          ),
        ),


        Text('min', style: TextStyle(fontSize: 14, color: Colors.black45)),
        SizedBox(
          width: 10,
        ),
        _RoundButton(
          text: "+${widget.initialStep}",
          onClick: onAdd,
          fontSize: 12,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final String text;
  final void Function() onClick;
  final Color color;
  final double fontSize;

  _RoundButton({
    required this.text,
    required this.onClick,
    Color? color,
    required this.fontSize,
  }) : color = color ?? Colors.blue[300]!;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: CircleBorder(),
      child: InkWell(
        onTap: onClick,
        customBorder: CircleBorder(),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
