import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class TtsService {
  final String apiKey;

  TtsService(this.apiKey);

  /// Sintetiza [text] usando ElevenLabs e retorna os bytes de áudio.
  Future<Uint8List> synthesize(
    String text, {
    String voiceId = 'nPczCjzI2devNBz1zQrb',
  }) async {
    final url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceId';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Accept': 'audio/mpeg',
        'Content-Type': 'application/json',
        'xi-api-key': apiKey,
      },
      body: json.encode({
        'text': text,
        'model_id': 'eleven_multilingual_v2',
        'voice_settings': {
          'stability': 0.5,
          'similarity_boost': 0.5,
          'style': 0.0,
        },
      }),
    );

    if (response.statusCode == 200) {
      return Uint8List.fromList(response.bodyBytes);
    }

    throw Exception('TTS request failed: ${response.statusCode}');
  }
}
