import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:flutter/material.dart';

class MultiSelectChip extends StatefulWidget {
  final List<String> dataList;
  final Function(List<String>) onSelectionChanged;
  MultiSelectChip(this.dataList, {required this.onSelectionChanged});
  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChoices = [];
  _buildChoiceList() {
    List<Widget> choices = [];
    widget.dataList.forEach(
      (item) {
        choices.add(
          Container(
            padding: const EdgeInsets.all(4.0),
            child: ChoiceChip(
              label: Text(
                item,
                style: selectedChoices.contains(item)
                    ? FontConstants.caption4
                    : FontConstants.caption2,
              ),
              selected: selectedChoices.contains(item),
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).primaryColorLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onSelected: (selected) {
                setState(() {
                  selectedChoices.contains(item)
                      ? selectedChoices.remove(item)
                      : selectedChoices.add(item);
                  widget.onSelectionChanged(selectedChoices);
                });
              },
            ),
          ),
        );
      },
    );
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
