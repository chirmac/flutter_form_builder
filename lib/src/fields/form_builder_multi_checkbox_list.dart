import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../form_builder_field_multi_option.dart';

class Option {
  final String name;
  final bool front;
  final bool back;

  Option(this.name, {this.back = false, this.front = false});

  //Option.fromJSON({@required this.label, @required this.value});

  bool operator ==(o) =>
      o is Option &&
      o.name == this.name &&
      o.front == this.front &&
      o.back == this.back;

  int get hashCode => name.hashCode ^ front.hashCode * back.hashCode;

  @override
  String toString() {
    return "Option: $name with values: Front - $front and Back - $back";
  }
}

class FormBuilderMultiCheckboxList extends StatefulWidget {
  final String attribute;
  final List<FormFieldValidator> validators;
  final dynamic initialValue;
  final bool readOnly;
  final InputDecoration decoration;
  final ValueChanged onChanged;
  final ValueTransformer valueTransformer;

  final List<FormBuilderFieldMultipleOption> options;
  final bool leadingInput;
  final Color activeColor;
  final Color checkColor;
  final MaterialTapTargetSize materialTapTargetSize;
  final bool tristate;
  final FormFieldSetter onSaved;

  FormBuilderMultiCheckboxList({
    Key key,
    @required this.attribute,
    @required this.options,
    this.initialValue,
    this.validators = const [],
    this.readOnly = false,
    this.leadingInput = false,
    this.decoration = const InputDecoration(),
    this.onChanged,
    this.valueTransformer,
    this.activeColor,
    this.checkColor,
    this.materialTapTargetSize,
    this.tristate = false,
    this.onSaved,
  }) : super(key: key);

  @override
  _FormBuilderMultiCheckboxListState createState() =>
      _FormBuilderMultiCheckboxListState();
}

class _FormBuilderMultiCheckboxListState
    extends State<FormBuilderMultiCheckboxList> {
  bool _readOnly = false;
  final GlobalKey<FormFieldState> _fieldKey = GlobalKey<FormFieldState>();
  FormBuilderState _formState;
  dynamic _initialValue;

  @override
  void initState() {
    _formState = FormBuilder.of(context);
    _formState?.registerFieldKey(widget.attribute, _fieldKey);
    _initialValue = widget.initialValue ??
        (_formState.initialValue.containsKey(widget.attribute)
            ? _formState.initialValue[widget.attribute]
            : null);
    super.initState();
  }

  @override
  void dispose() {
    _formState?.unregisterFieldKey(widget.attribute);
    super.dispose();
  }

  Widget _checkbox(FormFieldState<dynamic> field, int i, int j) {
    return InkWell(
      onTap: _readOnly
          ? null
          : () {
              FocusScope.of(context).requestFocus(FocusNode());
              var currValue = field.value;
              if (j == 0) {
                field.value[i].back = !field.value[i].back;
              } else {
                field.value[i].front = !field.value[i].front;
              }
              field.didChange(currValue);
              if (widget.onChanged != null) widget.onChanged(currValue);
            },
      child: Row(
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(left: 8),
              child: Tooltip(message: "${widget.options[i].values[j]}", child: Text(widget.options[i].values[j], overflow: TextOverflow.ellipsis,))),
          Checkbox(
            activeColor: widget.activeColor,
            checkColor: widget.checkColor,
            materialTapTargetSize: widget.materialTapTargetSize,
            tristate: widget.tristate,
            value: j == 0 ? field.value[i].back : field.value[i].front,
            onChanged: _readOnly
                ? null
                : (bool value) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    var currValue = field.value;
                    if (j == 0) {
                      field.value[i].back = !field.value[i].back;
                    } else {
                      field.value[i].front = !field.value[i].front;
                    }
                    field.didChange(currValue);
                    if (widget.onChanged != null) widget.onChanged(currValue);
                  },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _readOnly = (_formState?.readOnly == true) ? true : widget.readOnly;

    return FormField(
        key: _fieldKey,
        enabled: !_readOnly,
        initialValue: _initialValue ?? [],
        validator: (val) {
          for (int i = 0; i < widget.validators.length; i++) {
            if (widget.validators[i](val) != null)
              return widget.validators[i](val);
          }
          return null;
        },
        onSaved: (val) {
          var transformed;
          if (widget.valueTransformer != null) {
            transformed = widget.valueTransformer(val);
            _formState?.setAttributeValue(widget.attribute, transformed);
          } else
            _formState?.setAttributeValue(widget.attribute, val);
          if (widget.onSaved != null) {
            widget.onSaved(transformed ?? val);
          }
        },
        builder: (FormFieldState<dynamic> field) {
          List<Widget> checkboxList = [];
          for (int i = 0; i < widget.options.length; i++) {
            checkboxList.addAll([
              Material(
                type: MaterialType.transparency,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    widget.options[i].child,
                    Row(
                      children: <Widget>[
                        ...List.generate(2, (j) {
                          return _checkbox(field, i, j);
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                height: 0.0,
              ),
            ]);
          }
          return InputDecorator(
            decoration: widget.decoration.copyWith(
              enabled: !_readOnly,
              errorText: field.errorText,
              filled: false,
              border: InputBorder.none,
            ),
            child: Column(
              children: checkboxList,
            ),
          );
        });
  }
}
