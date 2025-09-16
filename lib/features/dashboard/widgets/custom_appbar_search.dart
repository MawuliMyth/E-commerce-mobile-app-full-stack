import 'package:flutter/material.dart';
import 'dart:developer';

class CustomAppbarSearch extends StatefulWidget {
  final String title;
  final Function(String) onSearchChanged;

  const CustomAppbarSearch({
    super.key,
    required this.title,
    required this.onSearchChanged,
  });

  @override
  State<CustomAppbarSearch> createState() => _CustomAppbarSearchState();
}

class _CustomAppbarSearchState extends State<CustomAppbarSearch> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
            const Spacer(),
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                fontFamily: 'qwerty',
                color: Colors.white,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search hostel/apartments",
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(
              Icons.search,
              color: Color.fromRGBO(63, 61, 86, 1),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Color.fromRGBO(63, 61, 86, 1)),
              onPressed: () {
                log("Clear button pressed");
                _searchController.clear();
                widget.onSearchChanged('');
              },
            )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            log("TextField onChanged: '$value'");
            widget.onSearchChanged(value);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}