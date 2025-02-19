import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:AiPlayer/src/bloc/ai/ai_bloc.dart';
import 'package:AiPlayer/src/core/theme/themes.dart';

class RecognizeSongView extends StatelessWidget {
  const RecognizeSongView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AIBloc, AIState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            gradient: Themes.getTheme().linearGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state is SongRecognized)
                  Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Recognized Song: ${state.songTitle}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  )
                else if (state is AIError)
                  Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  )
                else if (state is AIModelsLoading)
                    const CircularProgressIndicator()
                  else
                    IconButton(
                      onPressed: () {

                        context.read<AIBloc>().add(RecognizeSongEvent([]));
                      },
                      icon: const Icon(Icons.mic, size: 48),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}