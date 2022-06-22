import 'package:flutter/material.dart';

class FilterChips extends StatefulWidget {
  final String chiptext;

  const FilterChips({
    key,
    this.chiptext = '',
  }) : super(key: key);

  @override
  _FilterChipsState createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  var _filters = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 4),
          Wrap(
            spacing: 10, // to apply margin in the main axis of the wrap
            runSpacing: -6,
            children: [
              'Computer',
              'Hard Disk',
              'Laptop',
              'Lapctop',
              'Laptcop',
            ].map((filterType) {
              return FilterChip(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(30),
                ),
                label: Text(filterType, style: TextStyle(fontSize: 14)),
                selected: _filters.contains(filterType),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _filters.add(filterType);
                    } else {
                      _filters.removeWhere((name) {
                        return name == filterType;
                      });
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
