import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  final Color colour;
  final Widget cardChild;

  ReusableCard({@required this.colour, this.cardChild});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: cardChild,
      margin: EdgeInsets.all(15.0),
      color: colour,
      elevation: 5.0,
    );
  }
}
