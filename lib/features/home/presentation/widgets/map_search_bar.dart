import 'dart:async';
import 'dart:io';

import 'package:bullymap/features/home/data/services/location_search_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MapSearchBar extends StatefulWidget { 
  final ValueChanged<Map<String, dynamic>> onLocationSelected;
  
  const MapSearchBar({
    super.key,
    required this.onLocationSelected
  });

  @override
  State<StatefulWidget> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> with TickerProviderStateMixin {
  // Constants
  final LocationSearchService _locationSearchService = LocationSearchService();
  final TextEditingController _editingController = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  
  // States
  Timer? _debounce;
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  bool _isListening = false;

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

      setState(() {
        _suggestions = [];
      });

      _editingController.text = suggestion['name'] ?? '';

      widget.onLocationSelected(feature);
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

  void _onSpeechResult(SpeechRecognitionResult result) {
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

  // Widget methods
  @override
  void dispose() {
    _debounce?.cancel();
    _speech.cancel();
    _editingController.dispose(); 
    super.dispose();
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
            controller: _editingController,
            onChanged: _onSearchChanged,
            decoration: .new(
              hintText: "Search here...",

              prefixIcon: const Icon(Icons.search),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: !_isLoading ? IconButton(
                  onPressed: _onMicPressed,
                  icon: _isLoading ? const Icon(Icons.mic) : const Icon(Icons.mic_off),
                  color: _isListening ? Colors.redAccent : null,
                ) : const SizedBox(
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
              
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
            ),
          ),
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: _suggestions.isNotEmpty
              ? Container(
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

                  child: Material(
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
                  )
              : const SizedBox.shrink(),
        ),
      ]
    );
  }
}