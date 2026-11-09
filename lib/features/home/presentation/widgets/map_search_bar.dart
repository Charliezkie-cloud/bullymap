  import 'dart:async';

import 'package:bullymap/features/home/data/services/location_search_service.dart';
import 'package:flutter/material.dart';

class MapSearchBar extends StatefulWidget { 
  final ValueChanged<Map<String, dynamic>> onLocationSelected;
  
  const MapSearchBar({
    super.key,
    required this.onLocationSelected
  });

  @override
  State<StatefulWidget> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  // Constants
  final LocationSearchService _locationSearchService = LocationSearchService();
  final TextEditingController _editingController = TextEditingController();
  
  // States
  Timer? _debounce;
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;

  // Methods
  void _onSearchChanged(String query) {
    _debounce?.cancel();

    if (query.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
        setState(() => _isLoading = true);

        try {
          final results = await _locationSearchService.searchLocations(query);

          if (!mounted) return;

          setState(() {
            _suggestions = results;
            _isLoading = false;
          });
        } catch (e) {
          debugPrint('Location search error: $e');
          
          if (!mounted) return;

          setState(() {
            _suggestions = [];
            _isLoading = false;
          });
        }
      },
    );
  }

  Future<void> _selectLocation(Map<String, dynamic> suggestion) async {
    try {
      final feature = await _locationSearchService.retrieveLocation(
        suggestion['mapbox_id'],
      );

      if (!mounted) return;

      // Clear search results.
      setState(() {
        _suggestions = [];
      });

      // Put the selected location in the search field.
      _editingController.text = suggestion['name'] ?? '';

      // Notify the parent widget.
      widget.onLocationSelected(feature);
    } catch (e) {
      debugPrint('Location retrieval error: $e');
    }
  }

  // Widget methods
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(30),
          clipBehavior: Clip.antiAlias,
          child: TextField(
            controller: _editingController,
            onChanged: _onSearchChanged,
            decoration: .new(
              hintText: "Search here...",
              
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: !_isLoading ? IconButton(
                  onPressed: () => debugPrint("Microphone pressed"),
                  icon: const Icon(Icons.mic),
                ) : const SizedBox(
                  width: 40,
                  height: 48,
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
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
        ),

        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black12,
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              separatorBuilder: (a, b) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];

                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(
                    suggestion['name'] ?? '',
                  ),
                  subtitle: Text(
                    suggestion['place_formatted'] ?? '',
                  ),
                  onTap: () => _selectLocation(suggestion),
                );
              },
            ),
          ),
      ]
    );
  }
}