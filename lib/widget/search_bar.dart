
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../extension.dart';

class SearchBar extends StatefulWidget{

  final String label;
  final OnSearch onSearch;

  const SearchBar({Key? key, required this.label, required this.onSearch}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = '';
  }

  @override
  Widget build(BuildContext context) {
      return Container(
        height: 45,
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: Colors.white.withOpacity(0.4)
        ),
        alignment: Alignment.center,
        child: TextField(
          controller: _textEditingController,
          onSubmitted: widget.onSearch,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: widget.label
          ),
        ),
      );
  }

}