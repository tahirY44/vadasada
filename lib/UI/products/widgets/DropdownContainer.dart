import 'package:flutter/material.dart';

class DropdownContainer extends StatefulWidget {
  final Widget child;

  DropdownContainer({@required this.child});

  @override
  _DropdownContainerState createState() => _DropdownContainerState();
}

class _DropdownContainerState extends State<DropdownContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade500),
      ),
      child: widget.child,
    );
  }

  // DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         value: widget.value,
  //         isExpanded: true,
  //         items: widget.items.map((item) => _buildMenuItem(item)).toList(),
  //       ),
  //     )

  //
}
