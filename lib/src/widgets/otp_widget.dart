import 'package:flutter/material.dart';
import 'package:general_utilities/general_utilities.dart';

class OtpWidget extends StatefulWidget {
  const OtpWidget(
      {Key key,
      @required this.count,
      this.width = 100,
      this.fieldWidth = 20,
      this.keyboardType = TextInputType.number,
      this.textStyle = const TextStyle(),
      this.fieldsAlignment = MainAxisAlignment.spaceBetween,
      this.onChanged,
      this.onComplete})
      : assert(count > 1),
        super(key: key);

  final int count;

  final double width;

  final double fieldWidth;

  final TextInputType keyboardType;

  final TextStyle textStyle;

  final MainAxisAlignment fieldsAlignment;

  final ValueChanged<String> onChanged;

  final ValueChanged<String> onComplete;

  @override
  _OtpWidgetState createState() => _OtpWidgetState();
}

class _OtpWidgetState extends State<OtpWidget> {
  List<FocusNode> _focusNodes;
  List<TextEditingController> _controllers;

  List<Widget> _fields;
  List<String> _pins;

  @override
  void initState() {
    super.initState();

    _focusNodes = List<FocusNode>(widget.count);
    _controllers = List<TextEditingController>(widget.count);

    _pins = List.generate(widget.count, (int v) => '');

    _fields = List.generate(widget.count, (index) => _buildField(index));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: Row(
        mainAxisAlignment: widget.fieldsAlignment,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _fields,
      ),
    );
  }

  Widget _buildField(int index) {
    if (_focusNodes[index] == null) _focusNodes[index] = FocusNode();

    if (_controllers[index] == null)
      _controllers[index] = TextEditingController();

    return Container(
      width: widget.fieldWidth,
      padding: const EdgeInsets.all(kDimenNano),
      child: TextField(
        controller: _controllers[index],
        keyboardType: widget.keyboardType,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: widget.textStyle,
        focusNode: _focusNodes[index],
        decoration: InputDecoration(
          counterText: ""
        ),
        onChanged: (String s) {
          if (s.isEmpty) {
            if (index == 0) return;
            _focusNodes[index].unfocus();
            _focusNodes[index - 1].requestFocus();
          }

          setState(() {
            _pins[index] = s;
          });

          if (s.isNotEmpty) _focusNodes[index].unfocus();

          if (index + 1 != widget.count && s.isNotEmpty)
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);

          String currentPin = '';
          _pins.forEach((String value) {
            currentPin += value;
          });

          if (!_pins.contains(null) &&
              !_pins.contains('') &&
              currentPin.length == widget.count) {
            widget.onComplete(currentPin);
          }

          widget.onChanged(currentPin);
        },
      ),
    );
  }
}
