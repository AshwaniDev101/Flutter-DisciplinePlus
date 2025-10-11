import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FoodQuantitySelector extends StatefulWidget {
  final double initialValue;
  final double min;
  final double max;
  final double step;
  final int precision;
  final void Function(double oldValue, double newValue)? onChanged;
  final double buttonSize;
  final Color? buttonColor;
  final bool enableHoldToRepeat;

  const FoodQuantitySelector({
    Key? key,
    required this.initialValue,
    this.min = 0.0,
    this.max = 100,
    this.step = 1.0,
    this.precision = 1,
    this.onChanged,
    this.buttonSize = 30.0,
    this.buttonColor,
    this.enableHoldToRepeat = true,
  })  : assert(min <= max),
        assert(precision >= 0),
        super(key: key);

  @override
  State<FoodQuantitySelector> createState() => _FoodQuantitySelectorState();
}

class _FoodQuantitySelectorState extends State<FoodQuantitySelector> {
  late double _value;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _value = _clamp(widget.initialValue);
    _controller = TextEditingController(text: _format(_value));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant FoodQuantitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _setValue(widget.initialValue, notify: false);
    }
  }

  double _clamp(double v) => v.isNaN ? widget.min : v.clamp(widget.min, widget.max);

  String _format(double v) => v.toStringAsFixed(widget.precision);

  void _setValue(double v, {bool notify = true}) {
    final next = _clamp(v);
    if ((next - _value).abs() > (1e-12)) {
      final old = _value; // store old value
      setState(() {
        _value = next;
        _controller.text = _format(_value);
      });
      if (notify) widget.onChanged?.call(old, next);
    } else {
      _controller.text = _format(_value);
    }
  }

  void _changeBy(double delta, {bool notify = true}) {
    _setValue((_value + delta), notify: notify);
  }

  void _startAutoRepeat(double delta) {
    if (!widget.enableHoldToRepeat) return;
    _autoTimer?.cancel();
    _changeBy(delta);
    _autoTimer = Timer.periodic(const Duration(milliseconds: 150), (_) => _changeBy(delta));
  }

  void _stopAutoRepeat() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _commitTextField();
    } else {
      _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    }
  }

  void _commitTextField() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      _controller.text = _format(_value);
      return;
    }

    final normalized = raw.replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      _controller.text = _format(_value);
      return;
    }

    _setValue(parsed, notify: true);
  }

  @override
  void dispose() {
    _stopAutoRepeat();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
    required double repeatDelta,
    bool enabled = true,
  }) {
    final color = widget.buttonColor ?? Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      onLongPressStart: enabled && widget.enableHoldToRepeat ? (_) => _startAutoRepeat(repeatDelta) : null,
      onLongPressEnd: enabled && widget.enableHoldToRepeat ? (_) => _stopAutoRepeat() : null,
      onLongPressCancel: enabled && widget.enableHoldToRepeat ? () => _stopAutoRepeat() : null,
      child: Container(
        width: widget.buttonSize,
        height: widget.buttonSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.12) : Colors.grey.withOpacity(0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: widget.buttonSize * 0.55, color: enabled ? color : Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final minusEnabled = _value > widget.min;
    final plusEnabled = _value < widget.max;

    return Semantics(
      label: 'Quantity selector',
      value: _format(_value),
      increasedValue: _format(_clamp(_value + widget.step)),
      decreasedValue: _format(_clamp(_value - widget.step)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            enabled: minusEnabled,
            onTap: () => _changeBy(-widget.step),
            repeatDelta: -widget.step,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            height: 40,
            child: TextField(
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16.0,
              ),
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[\d\-,.]*$')),
              ],
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
              onSubmitted: (_) => _commitTextField(),
            ),
          ),
          const SizedBox(width: 10),
          _buildButton(
            icon: Icons.add,
            enabled: plusEnabled,
            onTap: () => _changeBy(widget.step),
            repeatDelta: widget.step,
          ),
        ],
      ),
    );
  }
}
