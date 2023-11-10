import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:flutter/material.dart';

class CustomAutocomplete extends StatefulWidget {
  final List<String> datalist;
  final TextEditingController textController;
  final Function(String) onSelected;
  final Color fillColor;
  final double maxWidth;

  CustomAutocomplete({
    required this.datalist,
    required this.textController,
    required this.onSelected,
    this.fillColor = ColorConstants.fillcolor,
    this.maxWidth = 300,
  });

  @override
  _CustomAutocompleteState createState() => _CustomAutocompleteState();
}

class _CustomAutocompleteState extends State<CustomAutocomplete> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        // if (textEditingValue.text == '') {
        //   return const Iterable<String>.empty();
        // }
        return widget.datalist.where((String option) {
          return option.contains(textEditingValue.text);
        });
      },
      onSelected: (String selection) {
        widget.onSelected(selection);
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        textEditingController.text = widget.textController.text;
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          style: FontConstants.body1,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: widget.maxWidth,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              height: 200,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((String option) {
                    return ListTile(
                      title: Text(
                        option,
                        style: FontConstants.body1,
                      ),
                      onTap: () {
                        onSelected(option);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
