import 'package:flutter/material.dart';

class SearchbarField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const SearchbarField({super.key, this.controller, this.onChanged});

  @override
  State<SearchbarField> createState() => _SearchbarFieldState();
}

class _SearchbarFieldState extends State<SearchbarField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: TextStyle(color: Color(0xffC7C7C7),),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
