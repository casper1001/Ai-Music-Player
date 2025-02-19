import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:AiPlayer/src/bloc/ai/ai_bloc.dart';

class LyricsPage extends StatelessWidget {
  final String lyrics;

  const LyricsPage({super.key, required this.lyrics});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lyrics'),
        actions: [
          IconButton(
            onPressed: () {
              // Trigger lyrics translation
              context.read<AIBloc>().add(TranslateLyricsEvent(lyrics));
            },
            icon: const Icon(Icons.translate),
            tooltip: 'Translate Lyrics',
          ),
        ],
      ),
      body: BlocListener<AIBloc, AIState>(
        listener: (context, state) {
          if (state is LyricsTranslated) {
            // Show the translated lyrics in a dialog
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Translated Lyrics'),
                  content: SingleChildScrollView(
                    child: Text(state.translatedLyrics),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          } else if (state is AIError) {
            // Show an error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(lyrics),
          ),
        ),
      ),
    );
  }
}