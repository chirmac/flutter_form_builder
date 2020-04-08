import 'package:flutter/material.dart';

class FormBuilderFieldMultipleOption extends StatelessWidget {
  final String label;
  final Widget child;
  final List<dynamic> values;

  FormBuilderFieldMultipleOption({
    Key key,
    this.label,
    @required this.values,
    this.child,
  })  : assert(
            child != null &&
            values != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}