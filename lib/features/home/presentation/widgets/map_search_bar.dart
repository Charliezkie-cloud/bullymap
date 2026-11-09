import 'package:flutter/material.dart';

class MapSearchBar extends StatefulWidget {
  const MapSearchBar({ super.key });

  @override
  State<StatefulWidget> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: TextField(
        decoration: .new(
          hintText: "Search here...",
          
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Padding(
            padding: .only(right: 8),
            child: IconButton(
              onPressed: () => debugPrint("Hello world from MapSearchBar widget"),
              icon: const Icon(Icons.mic)
            )
          ),
          
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
        ),
      ),
    );
  }
}