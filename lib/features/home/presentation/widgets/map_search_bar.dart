import 'dart:async';
import 'dart:io';

import 'package:bullymap/core/services/location_service.dart';
import 'package:bullymap/features/home/data/services/location_search_service.dart';
import 'package:bullymap/features/home/data/models/location_suggestion.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MapSearchBar extends StatefulWidget {
  // Constants
  final ValueChanged<LocationSuggestion> onSuggestionSelected;
  final ValueChanged<bool> onSearchFocusChanged;
  final ValueChanged<List<LocationSuggestion>> onSearchResults;
  final bool isSheetOpen;
  static final FocusNode _searchFocusNode = FocusNode();

  const MapSearchBar({
    super.key,
    required this.onSuggestionSelected,
    required this.onSearchResults,
    required this.onSearchFocusChanged,
    this.isSheetOpen = false,
  });

  // Methods
  static void focusSearchField() => _searchFocusNode.requestFocus();

  // Widget methods
  @override
  State<StatefulWidget> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  // Constants
  static const _minQueryLength = 2;
  static const _searchDebounce = Duration(milliseconds: 1000);

  final FocusNode _focusNode = MapSearchBar._searchFocusNode;
  final TextEditingController _searchController = TextEditingController();
  final SpeechToText _speech = SpeechToText();

  // States
  Timer? _debounceTimer;
  List<LocationSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _isListening = false;
  int _requestId = 0;

  // Methods
  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    final requestId = ++_requestId;

    if (query.trim().length < _minQueryLength) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    _debounceTimer = Timer(
      _searchDebounce,
      () => _loadSuggestions(query, requestId),
    );
  }

  Future<void> _loadSuggestions(String query, int requestId) async {
    if (!mounted) return;
    setState(() => _isSearching = true);

    try {
      final position = await LocationService.getCurrentLocation();
      final results = await LocationSearchService.suggestLocations(
        query,
        longitude: position.longitude,
        latitude: position.latitude,
      );
      if (!mounted || requestId != _requestId || widget.isSheetOpen) return;

      setState(() {
        _suggestions = results.map(LocationSuggestion.fromJson).toList();
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Location suggestion error: $e');
      if (!mounted || requestId != _requestId) return;

      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _onQuerySubmitted(String query) async {
    _debounceTimer?.cancel();
    final requestId = ++_requestId;
    setState(() {
      _suggestions = [];
      _isSearching = true;
    });

    try {
      final position = await LocationService.getCurrentLocation();
      final results = await LocationSearchService.searchLocations(
        query,
        longitude: position.longitude,
        latitude: position.latitude,
      );
      if (!mounted || requestId != _requestId) return;

      widget.onSearchResults(results.map(LocationSuggestion.fromJson).toList());
    } catch (e) {
      debugPrint('Location search error: $e');
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!_isListening) return;
    final words = result.recognizedWords;

    _searchController.text = words;
    _searchController.selection = TextSelection.collapsed(offset: words.length);
    _onQueryChanged(words);
  }

  void _showSpeechPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Microphone Permission Required'),
          content: const Text(
            'BullyMap needs access to your microphone and speech '
            'recognition to search places by voice. Please enable '
            'the permission in your application settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _onFocusChanged() {
    widget.onSearchFocusChanged(_focusNode.hasFocus);
  }

  Future<void> _onSuggestionSelected(LocationSuggestion suggestion) async {
    _debounceTimer?.cancel();
    _requestId++;

    if (_isListening) await _stopListening();
    if (!mounted) return;

    FocusScope.of(context).unfocus();
    _searchController.text = suggestion.name;

    setState(() {
      _suggestions = [];
      _isSearching = false;
    });

    // The results sheet is not populated here: closing the details sheet
    // must close everything instead of reopening the results sheet.
    widget.onSuggestionSelected(suggestion);
  }

  Future<void> _onMicPressed() async {
    if (_isListening) {
      await _stopListening();
      return;
    }

    if (!await _requestSpeechPermissions()) {
      if (mounted) _showSpeechPermissionDialog();
      return;
    }

    final granted = await _speech.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        debugPrint('Speech error: ${error.errorMsg}');
        if (mounted) setState(() => _isListening = false);
      },
    );

    if (!mounted) return;
    if (!granted) {
      _showSpeechPermissionDialog();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isListening = true);

    await _speech.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.search,
        partialResults: true,
        cancelOnError: true,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (mounted) setState(() => _isListening = false);
  }

  Future<bool> _requestSpeechPermissions() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) return false;

    if (Platform.isIOS) {
      final speech = await Permission.speech.request();
      if (!speech.isGranted) return false;
    }
    return true;
  }

  // Widget methods
  @override
  void initState() {
    super.initState();
  
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _speech.cancel();
    _searchController.dispose();
    _focusNode.removeListener(_onFocusChanged);

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MapSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSheetOpen && !oldWidget.isSheetOpen) {
      _debounceTimer?.cancel();
      _requestId++;
      if (_suggestions.isNotEmpty || _isSearching) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
    }
  }

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
            focusNode: _focusNode,
            controller: _searchController,
            onChanged: _onQueryChanged,
            onSubmitted: _onQuerySubmitted,
            decoration: .new(
              hintText: "Search here...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: !_isSearching
                    ? IconButton(
                        onPressed: _onMicPressed,
                        icon: Icon(_isListening ? Icons.mic : Icons.mic_off),
                        color: _isListening ? Colors.redAccent : null,
                      )
                    : const SizedBox(
                        width: 40,
                        height: 48,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: (_suggestions.isNotEmpty && !widget.isSheetOpen)
              ? _SuggestionList(
                  suggestions: _suggestions,
                  onSelected: _onSuggestionSelected,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _SuggestionList extends StatelessWidget {
  // Constants
  final List<LocationSuggestion> suggestions;
  final ValueChanged<LocationSuggestion> onSelected;

  const _SuggestionList({
    required this.suggestions,
    required this.onSelected,
  });

  // Widget methods
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black12),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 250,
          child: Material(
            color: Colors.transparent,
            child: Scrollbar(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(suggestion.name),
                    subtitle: Text(suggestion.placeFormatted),
                    onTap: () => onSelected(suggestion),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}