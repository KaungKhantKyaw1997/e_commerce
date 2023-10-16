import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:flutter/material.dart';

class MultiSelectChip extends StatefulWidget {
  final List<String> dataList;
  final List<String> selectedChoices;
  final Function(List<String>) onSelectionChanged;
  MultiSelectChip(this.dataList, this.selectedChoices,
      {required this.onSelectionChanged});
  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  _buildChoiceList() {
    List<Widget> choices = [];
    widget.dataList.forEach(
      (item) {
        choices.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(
                item,
                style: widget.selectedChoices.contains(item)
                    ? FontConstants.caption4
                    : FontConstants.caption2,
              ),
              selected: widget.selectedChoices.contains(item),
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).primaryColorLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onSelected: (selected) {
                setState(() {
                  widget.selectedChoices.contains(item)
                      ? widget.selectedChoices.remove(item)
                      : widget.selectedChoices.add(item);
                  widget.onSelectionChanged(widget.selectedChoices);
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
