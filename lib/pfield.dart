library pfield;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Pfield extends StatefulWidget {
  final InputDecoration? inputDecoration;
  final int count;
  final bool autoFocus;
  final TextInputType? keyboardType;
  final bool isError;
  final String? dialogText;
  final String? noDialog;
  final bool longPressClipboard;
  final String? yesDialog;
  final String inputValidExperssion;
  final TextEditingController? controller;
  const Pfield(
      {Key? key,
      this.count = 5,
      this.yesDialog,
      this.noDialog,
      this.dialogText,
      this.longPressClipboard = true,
      this.inputValidExperssion = r'\d+',
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
  bool? _isError;
  TextEditingController? _controller;
  final List<Map<String, dynamic>> pinController =
      List<Map<String, dynamic>>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    if (widget.count == 0) throw Exception("at least one pin field.");
    if (widget.controller != null) {
      _controller = widget.controller;
      _controller!.addListener(parentControllerChanged);
    } else {
      _controller = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    _isError = widget.isError;
    //prevent un-necessary rebuild
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
            node.onKeyEvent = ((node, event) {
              if (event is KeyUpEvent) {
                if (event.logicalKey.keyLabel == "Backspace" &&
                    pinController[i]["controller"].text == '') {
                  if (i != 0) {
                    pinController[i - 1]["controller"].text = '';
                    pinController[i - 1]["focusNode"].requestFocus();
                  }
                }
              }
              return KeyEventResult.ignored;
            });
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

  void textControllerChanged({bool force = false}) {
    if (_controller != null) {
      String allValues = pinController.map((e) => e["controller"].text).join();
      if (force) {
        parentControllerChanged();
        return;
      } else if (allValues != _controller!.text) {
        _controller!.removeListener(parentControllerChanged);
        _controller!.text = allValues;
        _controller!.addListener(parentControllerChanged);
      }
    }
  }

  void parentControllerChanged() {
    String validValue = RegExp(widget.inputValidExperssion)
        .allMatches(_controller!.text)
        .map((e) => e.group(0))
        .join();
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          pinController[index]["focusNode"].requestFocus();
          tappedTextBox(index);
        },
        onLongPress: () => clipBoardDialogBuilder(context),
        child: IgnorePointer(
          child: TextField(
            enableInteractiveSelection: false,
            keyboardType: widget.keyboardType,
            onChanged: (text) => ontextChanged(text, index),
            autofocus: widget.autoFocus,
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
        ),
      ),
    );
  }

  void clipBoardDialogBuilder(BuildContext context) async {
    if (!widget.longPressClipboard) return;
    AlertDialog alert = AlertDialog(
      content:
          Text(widget.dialogText ?? 'Do you want to paste from clipboard ?'),
      actions: [
        TextButton(
            onPressed: () {
              Clipboard.getData('text/plain').then((data) {
                if (data!.text!.isNotEmpty) {
                  _controller!.text = data.text!;
                }
              });
              Navigator.pop(context);
            },
            child: Text(widget.yesDialog ?? 'Yes')),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(widget.noDialog ?? 'No')),
      ],
    );
    await showDialog(context: context, builder: (context) => alert);
  }

  InputDecoration buildInputDecoration(BuildContext context, int index) {
    inputDecoration = widget.inputDecoration ??
        InputDecoration(
          fillColor: _isError! ? Colors.red[50] : null,
          filled: _isError! ? true : null,
          focusedBorder: _isError!
              ? const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                )
              : null,
          enabledBorder: _isError!
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

  void ontextChanged(String value, int index) {
    if (value.isEmpty) {
      if (index == 0) {
        pinController[index]["focusNode"].requestFocus();
        return;
      }
      for (var j = index; j < widget.count - 1; j++) {
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
      return;
    }
    int aindex = index < widget.count - 1 ? index + 1 : widget.count - 1;
    final anode = pinController[aindex]["focusNode"] as FocusNode;
    if (value.isNotEmpty &&
        !RegExp(widget.inputValidExperssion).hasMatch(value)) {
      textControllerChanged(force: true);
      return;
    }

    anode.requestFocus();
  }
}
