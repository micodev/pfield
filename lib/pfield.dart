library pfield;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Pfield extends StatefulWidget {
  final InputDecoration? inputDecoration;
  final int count;
  final bool autoFocus;
  final TextInputType? keyboardType;
  final bool isError;
  final TextEditingController? controller;
  const Pfield(
      {Key? key,
      this.count = 5,
      this.keyboardType = TextInputType.number,
      this.controller,
      this.inputDecoration,
      this.autoFocus = false,
      this.isError = false})
      : super(key: key);

  @override
  State<Pfield> createState() => _PfieldState();
}

class _PfieldState extends State<Pfield> {
  InputDecoration? inputDecoration;

  final List<Map<String, dynamic>> pinController =
      List<Map<String, dynamic>>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    if (widget.count == 0) throw Exception("على الأقل حقل واحد");
    if (widget.controller != null) {
      widget.controller!.addListener(parentControllerChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pinController.length != widget.count) pinController.clear();
    final width = MediaQuery.of(context).size.width;
    double containerWidth = width / (widget.count + 1);
    containerWidth = containerWidth > 100 ? 100 : containerWidth;
    containerWidth = containerWidth < 31 ? 31 : containerWidth;
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      direction: Axis.horizontal,
      children: [
        ...List.generate(widget.count, (index) => index).map(
          (i) {
            if (pinController.length != widget.count) {
              pinController.add({
                "controller": TextEditingController(),
                "focusNode": FocusNode(),
              });
              final controller =
                  pinController[i]["controller"] as TextEditingController;
              controller.addListener(textControllerChanged);
            }
            final node = pinController[i]["focusNode"] as FocusNode;
            node.onKeyEvent = (node, event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey.keyLabel == "Backspace") {
                  pinController[i]["controller"].text = "";
                  for (var j = i; j < widget.count - 1; j++) {
                    var swap = pinController[j + 1]["controller"].text;
                    pinController[j + 1]["controller"].text =
                        pinController[j]["controller"].text;
                    pinController[j]["controller"].text = swap;
                  }
                  for (var j = widget.count - 1; j >= 0; j--) {
                    if (pinController[j]["controller"].text.isEmpty && j > 0) {
                      pinController[j - 1]["focusNode"].requestFocus();
                    }
                  }
                } else if (event.character != null &&
                    RegExp('[0-9]').hasMatch(event.character!)) {
                  for (var j = 0; j < widget.count; j++) {
                    if (pinController[j]["controller"].text.isEmpty) {
                      pinController[j]["controller"].text = event.character;
                      if (j < widget.count - 1) {
                        pinController[j + 1]["focusNode"].requestFocus();
                      }
                      break;
                    }
                  }
                }
              }
              return KeyEventResult.handled;
            };
            return SizedBox(
              width: containerWidth,
              child:
                  buildText(context, i, node, pinController[i]["controller"]),
            );
          },
        ).toList()
      ],
    );
  }

  void tappedTextBox(int index) {
    if (index > 0 && pinController[index - 1]["controller"].text.isEmpty) {
      for (int i = index - 1; i >= 0; i--) {
        if (pinController[i]["controller"].text.isNotEmpty) {
          pinController[i + 1]["focusNode"].requestFocus();
          break;
        } else if (i == 0) {
          pinController[i]["focusNode"].requestFocus();
        }
      }
    }
  }

  void textControllerChanged() {
    if (widget.controller != null) {
      String allValues = pinController.map((e) => e["controller"].text).join();
      if (allValues != widget.controller!.text) {
        widget.controller!.removeListener(parentControllerChanged);
        widget.controller!.text = allValues;
        widget.controller!.addListener(parentControllerChanged);
      }
    }
  }

  void parentControllerChanged() {
    String validValue =
        widget.controller!.text.replaceAll(RegExp(r'[^0-9]'), '');

    var i = 0;
    for (; i < validValue.length && i < widget.count; i++) {
      pinController[i]["controller"].removeListener(textControllerChanged);
      pinController[i]["controller"].text = validValue[i];
      pinController[i]["controller"].addListener(textControllerChanged);
    }
    for (; i < widget.count; i++) {
      pinController[i]["controller"].removeListener(textControllerChanged);
      pinController[i]["controller"].text = "";
      pinController[i]["controller"].addListener(textControllerChanged);
    }
  }

  Widget buildText(BuildContext context, int index, FocusNode node,
      TextEditingController controller) {
    return Material(
      child: TextField(
        keyboardType: widget.keyboardType,
        autofocus: widget.autoFocus,
        onTap: () => tappedTextBox(index),
        focusNode: node,
        controller: controller,
        maxLines: 1,
        buildCounter: (
          BuildContext context, {
          required int currentLength,
          required int? maxLength,
          required bool isFocused,
        }) {
          return null;
        },
        decoration: buildInputDecoration(context, index),
        textAlign: TextAlign.center,
        maxLength: 1,
      ),
    );
  }

  InputDecoration buildInputDecoration(BuildContext context, int index) {
    inputDecoration = widget.inputDecoration ??
        InputDecoration(
          fillColor: widget.isError ? Colors.red[50] : null,
          filled: widget.isError ? true : null,
          focusedBorder: widget.isError
              ? const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                )
              : null,
          enabledBorder: widget.isError
              ? const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                )
              : null,
          isDense: true,
        );
    return inputDecoration!;
  }
}
