import 'dart:async';
import 'dart:io';

import 'package:bullymap/core/services/location_service.dart';
import 'package:bullymap/features/home/data/services/location_search_service.dart';
import 'package:bullymap/features/home/models/location_suggestion.dart';
import 'package:bullymap/features/home/models/pinned_location.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MapSearchBar extends StatefulWidget {
  // Constants
  final ValueChanged<PinnedLocation> onLocationSelected;
  final void Function(bool) onSearchFocused;
  final void Function(List<LocationSuggestion>) onMapSearchBarResults;
  final bool isShowSheets;

  const MapSearchBar({
    super.key,
    required this.onLocationSelected,
    required this.onMapSearchBarResults,
    required this.onSearchFocused,
    this.isShowSheets = false,
  });

  // Widget methods
  @override
  State<StatefulWidget> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  // Constants
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _editingController = TextEditingController();
  final SpeechToText _speech = SpeechToText();

  // States
  Timer? _debounce;
  List<LocationSuggestion> _suggestions = [];
  bool _isLoading = false;
  bool _isListening = false;
  int _searchId = 0;

  // Methods
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    final id = ++_searchId;

    if (query.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (!mounted) return;
      setState(() => _isLoading = true);

      try {
        final currentLocation = await LocationService.getCurrentLocation();
        final lng = currentLocation.longitude;
        final lat = currentLocation.latitude;
        final results = await LocationSearchService.suggestLocations(query, longitude: lng, latitude: lat);
        if (!mounted || id != _searchId || widget.isShowSheets) return;

        setState(() {
          _suggestions = results.map(LocationSuggestion.fromJson).toList();
          _isLoading = false;
        });
      } catch (e) {
        debugPrint('Location search error: $e');
        if (!mounted || id != _searchId) return;
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    });
  }

  void _onSearchSubmitted(String query) async {
    _debounce?.cancel();
    final id = ++_searchId;
    setState(() { _suggestions = []; _isLoading = true; });
    
    try {
      final loc = await LocationService.getCurrentLocation();
      final results = await LocationSearchService.searchLocations(query, longitude: loc.longitude, latitude: loc.latitude);
      if (!mounted || id != _searchId) return;

      widget.onMapSearchBarResults(results.map(LocationSuggestion.fromJson).toList());
    } catch (e) {
      debugPrint('Location search error: $e');
    } finally {
      if (mounted && id == _searchId) setState(() => _isLoading = false);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!_isListening) return;
    final words = result.recognizedWords;

    _editingController.text = words;
    _editingController.selection = TextSelection.collapsed(offset: words.length);
    _onSearchChanged(words);
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
    widget.onSearchFocused(_focusNode.hasFocus);
  }

  Future<void> _selectLocation(LocationSuggestion suggestion) async {
    _debounce?.cancel();
    _searchId++;

    if (_isListening) await _stopListening();
    if (!mounted) return;

    FocusScope.of(context).unfocus();
    _editingController.text = suggestion.name;
    setState(() {
      _suggestions = [];
      _isLoading = false;
    });

    try {
      final feature = await LocationSearchService.retrieveLocation(suggestion.mapboxId);
      if (!mounted) return;
      widget.onLocationSelected(PinnedLocation.fromMapboxFeature(feature));
    } catch (e) {
      debugPrint('Location retrieval error: $e');
    }
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
    _debounce?.cancel();
    _speech.cancel();
    _editingController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MapSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShowSheets && !oldWidget.isShowSheets) {
      _debounce?.cancel();
      _searchId++;
      if (_suggestions.isNotEmpty || _isLoading) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
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
            controller: _editingController,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
            decoration: .new(
              hintText: "Search here...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: !_isLoading
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
          child: (_suggestions.isNotEmpty && !widget.isShowSheets)
              ? Container(
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
                            itemCount: _suggestions.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index];
                              return ListTile(
                                leading: const Icon(Icons.location_on_outlined),
                                title: Text(suggestion.name),
                                subtitle: Text(suggestion.placeFormatted),
                                onTap: () => _selectLocation(suggestion),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}