import 'package:flutter/material.dart';

import 'package:remember/widgets/app_scaffold.dart';

class EventsTab extends StatefulWidget {
  @override
  _EventsTabState createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Account',
    );
  }
}
